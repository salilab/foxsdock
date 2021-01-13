from flask import request, abort, send_from_directory
import saliweb.frontend
import collections
import subprocess
import re
import os
import shutil

Transform = collections.namedtuple(
    'Transform', ['number', 'zscore', 'saxs_score', 'energy_score',
                  'transform', 'pdb', 'fit'])


def get_transforms(job, show_from, show_to):
    num_transforms = 0
    transforms = []
    with open(job.get_path('results_saxs.txt')) as fh:
        for line in fh:
            spl = line.rstrip('\r\n').split("|")
            if len(spl) > 1 and not line.startswith('     # |'):
                num_transforms += 1
                if num_transforms >= show_from and num_transforms <= show_to:
                    trans = spl[-1].split()
                    trans = " ".join("%.2f" % float(t) for t in trans)
                    transforms.append(Transform(
                        number=num_transforms,
                        zscore=spl[1].strip(),
                        saxs_score=spl[4].strip(),
                        energy_score=spl[6].strip(),
                        transform=trans, pdb="result%d.pdb" % num_transforms,
                        fit="fit%d" % num_transforms))
    return num_transforms, transforms


def read_input_txt(job):
    with open(job.get_path('input.txt')) as fh:
        spl = fh.readline().rstrip('\r\n').split(' ')
        return spl[0], spl[1], spl[3], spl[5]


def show_results_page(job):
    show_from = get_int('from', 1)
    show_to = get_int('to', 20)
    receptor, ligand, profile, complex_type = read_input_txt(job)

    num_transforms, transforms = get_transforms(job, show_from, show_to)
    return saliweb.frontend.render_results_template(
        "results_ok.html",
        receptor=receptor, ligand=ligand, profile=profile,
        complex_type=complex_type,
        transforms=transforms, show_from=show_from, show_to=show_to,
        num_transforms=num_transforms, job=job)


def get_model_fit_page(job, fp, config):
    m = re.match(r"fit(\d+)$", fp)
    trans_num = int(m.group(1))
    dockpdb = get_dock_pdb(job, trans_num, config)
    if dockpdb:
        pdb_code = os.path.splitext(dockpdb)[0]
        receptor, ligand, profile, complex_type = read_input_txt(job)
        chi, c1, c2 = get_foxs_fit(job, dockpdb, profile, trans_num, config)
        fitpng = "%s_%s.png" % (pdb_code, os.path.splitext(profile)[0])
        if not os.path.exists(job.get_path(fitpng)):
            fitpng = None
        fitdat = "%s_%s.dat" % (pdb_code, os.path.splitext(profile)[0])
        return saliweb.frontend.render_results_template(
            "fit.html",
            job=job, number=trans_num, profile=profile, dockpdb=dockpdb,
            fitpng=fitpng, fitdat=fitdat, pdb_code=pdb_code,
            chi=chi, c1=c1, c2=c2)
    else:
        abort(404)


def get_foxs_fit(job, pdb, profile, trans_num, config):
    foxs_log = job.get_path("foxs_%d.log" % trans_num)
    if not os.path.exists(foxs_log):
        foxs = config['FOXSDOCK_FOXS']
        out = subprocess.check_output(
                [foxs, '-g', pdb, profile], cwd=job.directory)
        gnuplot = config['FOXSDOCK_GNUPLOT']
        os.path.splitext(profile)[0]
        subprocess.check_call(
            [gnuplot,
             "docking_%d_%s.plt" % (trans_num, os.path.splitext(profile)[0])],
            cwd=job.directory)
        with open(foxs_log, 'wb') as fh:
            fh.write(out)

    r = re.compile(r'Chi\^2 = (\S+) c1 = (\S+) c2 = (\S+)')
    with open(foxs_log) as fh:
        for line in fh:
            m = r.search(line)
            if m:
                return m.group(1), m.group(2), m.group(3)


def get_model_pdb(job, fp, config):
    m = re.match(r"result(\d+)\.pdb", fp)
    trans_num = int(m.group(1))
    dockpdb = get_dock_pdb(job, trans_num, config)
    if dockpdb:
        return send_from_directory(job.directory, dockpdb)
    else:
        abort(404)


def get_dock_pdb(job, trans_num, config):
    num_transforms = 0
    with open(job.get_path('results_saxs.txt')) as fh:
        for line in fh:
            if line.startswith('receptorPdb'):
                receptor = line.rstrip('\r\n').split()[-1]
            elif line.startswith('ligandPdb'):
                ligand = line.rstrip('\r\n').split()[-1]
            else:
                spl = line.rstrip('\r\n').split("|")
                if len(spl) > 1 and not line.startswith('     # |'):
                    num_transforms += 1
                    if num_transforms == trans_num:
                        return apply_trans(job, receptor, ligand, trans_num,
                                           spl[-1], config)


def apply_trans(job, receptor, ligand, trans_num, trans, config):
    dockfile = "docking_%d.pdb" % trans_num
    pth = job.get_path(dockfile)
    if not os.path.exists(pth):
        with open(pth, 'wb') as fh:
            with open(job.get_path(receptor), 'rb') as fh_in:
                shutil.copyfileobj(fh_in, fh)
            pdb_trans = config['FOXSDOCK_PDB_TRANS']
            with open(job.get_path(ligand), 'rb') as fh_in:
                out = subprocess.check_output(
                        [pdb_trans] + trans.split(), stdin=fh_in)
                fh.write(out)
    return dockfile


def get_int(name, default):
    try:
        return int(request.args.get(name, ""))
    except ValueError:
        return default
