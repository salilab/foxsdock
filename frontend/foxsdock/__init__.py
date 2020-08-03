from flask import render_template, request, send_from_directory, abort
import saliweb.frontend
from saliweb.frontend import get_completed_job, Parameter, FileParameter
import os
import re
from . import submit_page, results_page

parameters = []
app = saliweb.frontend.make_application(__name__, parameters)


@app.route('/')
def index():
    return render_template('index.html')


@app.route('/help')
def help():
    return render_template('help.html')


@app.route('/about')
def about():
    return render_template('about.html')


@app.route('/download')
def download():
    return render_template('download.html')


@app.route('/links')
def links():
    return render_template('links.html')


@app.route('/job', methods=['GET', 'POST'])
def job():
    if request.method == 'GET':
        return saliweb.frontend.render_queue_page()
    else:
        return submit_page.handle_new_job()


@app.route('/results.cgi/<name>')  # compatibility with old perl-CGI scripts
@app.route('/job/<name>')
def results(name):
    job = get_completed_job(name, request.args.get('passwd'))
    if os.path.exists(job.get_path("results_saxs.txt")):
        return results_page.show_results_page(job)
    else:
        return saliweb.frontend.render_results_template("results_failed.html",
                                                        job=job)


@app.route('/job/<name>/<path:fp>')
def results_file(name, fp):
    job = get_completed_job(name, request.args.get('passwd'))
    if re.match(r'fit\d+$', fp):
        return results_page.get_model_fit_page(job, fp, app.config)
    elif re.match(r'result\d+\.pdb$', fp):
        return results_page.get_model_pdb(job, fp, app.config)
    else:
        return send_from_directory(job.directory, fp)
