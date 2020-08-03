from flask import request
import saliweb.frontend
from saliweb.frontend import InputValidationError
from werkzeug.utils import secure_filename
import os


def handle_new_job():
    profile = request.form.get('saxsfile')
    email = request.form.get('email')
    moltype = request.form.get('moltype')
    weighted_score = request.form.get('weighted')

    # Validate input
    moltype = {'Enzyme-inhibitor': 'EI',
               'Antibody-antigen': 'AA',
               'Default': 'Default'}.get(moltype)
    if not moltype:
        raise InputValidationError("Error in the types of molecules")
    saliweb.frontend.check_email(email, required=False)

    job = saliweb.frontend.IncomingJob()
    receptor = handle_pdb(request.form.get("receptor"),
                          request.files.get("recfile"), "receptor", job)
    ligand = handle_pdb(request.form.get("ligand"),
                          request.files.get("ligfile"), "ligand", job)

    saxsfile = handle_uploaded_file(
            request.files.get("saxsfile"), job, "SAXS profile file")
    distfile = handle_uploaded_file(
            request.files.get("distfile"), job, "distance constraints file",
            force_name="distance_constraints.txt")

    # write parameters
    with open(job.get_path('input.txt'), 'w') as fh:
        fh.write("%s %s --saxs %s --complex_type %s"
                 % (receptor, ligand, saxsfile, moltype))
        if weighted_score:
            fh.write(" --weighted_saxs_score")
        fh.write("\n")
    with open(job.get_path('data.txt'), 'w') as fh:
        fh.write("%s %s --saxs %s --complex_type %s %s\n"
                 % (receptor, ligand, saxsfile, moltype, email))

    job.submit(email)

    # Pop up an exit page
    return saliweb.frontend.render_submit_template('submit.html', email=email,
                                                   job=job)


def handle_pdb(pdb_code, pdb_file, pdb_type, job):
    """Handle input PDB code or file. Return file name."""
    if pdb_file:
        fname = secure_filename(os.path.basename(pdb_file.filename))
        # Cannot call input files docking.res.X.pdb (reserved for output files)
        fname = fname.replace('docking.res.', 'dockingres.')
        full_fname = job.get_path(fname)
        pdb_file.save(full_fname)
        if os.stat(full_fname).st_size == 0:
            raise InputValidationError("You have uploaded an empty %s PDB file"
                                       % pdb_type)
        return fname
    elif pdb_code:
        fname = saliweb.frontend.get_pdb_chains(pdb_code, job.directory)
        return [os.path.basename(fname)]
    else:
        raise InputValidationError("Error in protein input: please specify "
                                   "PDB code or upload file for %s" % pdb_type)


def handle_uploaded_file(fh, job, description, force_name=None):
    """Save an uploaded file into the job directory.
       Return the filename (sanitized) or "-" if not specified."""
    if not fh:
        return "-"
    fname = force_name or secure_filename(fh.filename)
    full_fname = job.get_path(fname)
    fh.save(full_fname)
    if os.stat(full_fname).st_size == 0:
        raise InputValidationError("You have uploaded an empty %s"
                                   % description)
    return fname
