from flask import request
import saliweb.frontend
from saliweb.frontend import InputValidationError
from werkzeug.utils import secure_filename
import os
import re


def handle_new_job():
    email = request.form.get('email')

    jobname = request.form.get('jobname')
    modelsnumber = request.form.get('modelsnumber', type=int)
    units = request.form.get('units')

    # Validate input
    saliweb.frontend.check_email(email, required=False)
    if modelsnumber is None or modelsnumber <= 0 or modelsnumber > 10000:
        raise InputValidationError(
                "Invalid value for number of models. "
                "Must be > 0 and <= 10000")
    if units not in ("unknown", "angstroms", "nanometers"):
        raise InputValidationError("Invalid units: %s" % units)

    job = saliweb.frontend.IncomingJob(jobname)
    pdb_file_name = handle_pdb(request.form.get('pdbcode'),
                               request.files.get("pdbfile"), job)

    saxsfile = handle_uploaded_file(
            request.files.get("saxsfile"), job, "iq.dat", "SAXS profile file")
    hingefile = handle_uploaded_file(
            request.files.get("hingefile"), job, "hinges.dat",
            "flexible residues file")

    real_connect = "connectrbs.dat"
    connectrbsfile = handle_uploaded_file(
            request.files.get("connectrbsfile"), job, real_connect,
            "rigid bodies connect file", allow_missing=True)

    # write parameters
    with open(job.get_path('input.txt'), 'w') as fh:
        fh.write("%s hinges.dat iq.dat %s %s %s\n"
                 % (pdb_file_name,
                    real_connect if os.path.exists(job.get_path(real_connect))
                                 else "-",
                    modelsnumber, units))
    with open(job.get_path('data.txt'), 'w') as fh:
        fh.write("%s %s %s %s %s %s %d\n"
                 % (pdb_file_name, hingefile, saxsfile, email, jobname,
                    connectrbsfile, modelsnumber))

    job.submit(email)

    # Pop up an exit page
    return saliweb.frontend.render_submit_template('submit.html', email=email,
                                                   job=job)


def has_atoms(fname):
    """Return True iff fname has at least one ATOM record"""
    with open(fname) as fh:
        for line in fh:
            if line.startswith('ATOM  '):
                return True


def handle_pdb(pdb_code, pdb_file, job):
    """Handle input PDB code or file. Return file name."""
    if pdb_file:
        fname = 'input.pdb'
        full_fname = job.get_path(fname)
        pdb_file.save(full_fname)
        if not has_atoms(full_fname):
            raise InputValidationError("PDB file contains no ATOM records!")
        return fname
    elif pdb_code:
        fname = saliweb.frontend.get_pdb_chains(pdb_code, job.directory)
        return [os.path.basename(fname)]
    else:
        raise InputValidationError("Error in protein input: please specify "
                                   "PDB code or upload file")


def handle_uploaded_file(fh, job, output_file, description,
                         allow_missing=False):
    """Save an uploaded file into the job directory.
       Return the user-specified filename (sanitized)."""
    if not fh:
        if not allow_missing:
            raise InputValidationError("Please upload valid %s" % description)
        return
    full_fname = job.get_path(output_file)
    fh.save(full_fname)
    if os.stat(full_fname).st_size == 0:
        raise InputValidationError("You have uploaded an empty %s"
                                   % description)
    return secure_filename(os.path.basename(fh.filename))
