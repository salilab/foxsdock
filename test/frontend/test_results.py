import unittest
import saliweb.test
import re
import os
import tempfile

# Import the foxsdock frontend with mocks
foxsdock = saliweb.test.import_mocked_frontend("foxsdock", __file__,
                                               '../../frontend')


class MockJob(object):
    def __init__(self, cwd):
        self.directory = cwd

    def get_path(self, fname):
        return os.path.join(self.directory, fname)

    def make_file(self, fname, contents):
        pth = self.get_path(fname)
        with open(pth, 'w') as fh:
            fh.write(contents)
        return pth

    def make_exe(self, fname, contents):
        pth = self.make_file(fname, contents)
        os.chmod(pth, 0o755)
        return pth


def make_input_txt(j):
    j.make_file(
        'input.txt',
        '5_new.pdb ICAM_Btype.pdb --saxs iq.dat --complex_type Default')


class Tests(saliweb.test.TestCase):
    """Check results page"""

    def test_results_file(self):
        """Test download of results files"""
        with saliweb.test.make_frontend_job('testjob') as j:
            # Good file
            j.make_file('good.log')
            c = foxsdock.app.test_client()
            rv = c.get('/job/testjob/good.log?passwd=%s' % j.passwd)
            self.assertEqual(rv.status_code, 200)

    def test_ok_job(self):
        """Test display of OK job"""
        with saliweb.test.make_frontend_job('testjob2') as j:
            make_input_txt(j)
            j.make_file(
                "results_saxs.txt",
                "receptorPdb Str 5_new.pdb\n"
                "ligandPdb Str ICAM_Btype.pdb\n"
                "     # |  Score  | filt| ZScore |  SAXS  | Zscore "
                "|  SOAP     | Zscore | Transformation\n"
                "     1 |  -3.559 |  +  | -2.503 |  2.147 | -1.055 "
                "| -1610.932 | -2.504 |  -1.636 -0.108 0.361 -40.146 "
                "-84.326 -72.529\n"
                "     2 |  -3.461 |  +  | -2.434 |  1.812 | -1.292 "
                "| -1429.678 | -2.169 |  -1.357 0.112 0.608 -29.160 "
                "-68.705 -80.858\n")
            c = foxsdock.app.test_client()
            rv = c.get('/job/testjob2?passwd=%s&from=1&to=20' % j.passwd)
            r = re.compile(
                    rb'Receptor.*Ligand.*SAXS Profile.*Complex Type.*'
                    rb'job\/testjob2\/5_new\.pdb\?passwd=.*'
                    rb'Model No.*Z\-Score.*Download output file',
                    re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)

    def test_failed_job(self):
        """Test display of failed job"""
        with saliweb.test.make_frontend_job('testjob3') as j:
            make_input_txt(j)
            c = foxsdock.app.test_client()
            rv = c.get('/job/testjob3?passwd=%s&from=1&to=20' % j.passwd)
            r = re.compile(
                    rb'No output file was produced.*'
                    rb'job\/testjob3\/foxsdock\.log\?passwd=.*'
                    rb'job\/testjob3\/patch_dock\.log\?passwd=.*',
                    re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)

    def test_get_model_fit_no_fit(self):
        """Test get_model_fit_page, no fit"""
        with saliweb.test.make_frontend_job('testjob4') as j:
            make_input_txt(j)
            j.make_file("docking_2.pdb")
            j.make_file("foxs_2.log", """
1abc.pdb saxs.dat Chi^2 = 28.2913 c1 = 1.05 c2 = 4 default chi^2 = 45.8281""")
            j.make_file(
                "results_saxs.txt",
                "receptorPdb Str 5_new.pdb\n"
                "ligandPdb Str ICAM_Btype.pdb\n"
                "     # |  Score  | filt| ZScore |  SAXS  | Zscore "
                "|  SOAP     | Zscore | Transformation\n"
                "     1 |  -3.559 |  +  | -2.503 |  2.147 | -1.055 "
                "| -1610.932 | -2.504 |  -1.636 -0.108 0.361 -40.146 "
                "-84.326 -72.529\n"
                "     2 |  -3.461 |  +  | -2.434 |  1.812 | -1.292 "
                "| -1429.678 | -2.169 |  -1.357 0.112 0.608 -29.160 "
                "-68.705 -80.858\n")
            c = foxsdock.app.test_client()
            rv = c.get('/job/testjob4/fit2?passwd=%s' % j.passwd)
            r = re.compile(
                    rb'docking_2 Fit to experimental profile.*'
                    rb'Profile fit not generated.*docking_2_iq\.dat.*'
                    rb'Experimental profile fit file.*'
                    rb'\&chi;<sup>2</sup> = 28.2913 c<sub>1</sub> = 1.05 '
                    rb'c<sub>2</sub> = 4',
                    re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)

    def test_get_model_fit(self):
        """Test get_model_fit_page, with fit"""
        with saliweb.test.make_frontend_job('testjob4') as j:
            make_input_txt(j)
            j.make_file("docking_2.pdb")
            j.make_file("docking_2_iq.png")
            j.make_file("foxs_2.log", """
1abc.pdb saxs.dat Chi^2 = 28.2913 c1 = 1.05 c2 = 4 default chi^2 = 45.8281""")
            j.make_file(
                "results_saxs.txt",
                "receptorPdb Str 5_new.pdb\n"
                "ligandPdb Str ICAM_Btype.pdb\n"
                "     # |  Score  | filt| ZScore |  SAXS  | Zscore "
                "|  SOAP     | Zscore | Transformation\n"
                "     1 |  -3.559 |  +  | -2.503 |  2.147 | -1.055 "
                "| -1610.932 | -2.504 |  -1.636 -0.108 0.361 -40.146 "
                "-84.326 -72.529\n"
                "     2 |  -3.461 |  +  | -2.434 |  1.812 | -1.292 "
                "| -1429.678 | -2.169 |  -1.357 0.112 0.608 -29.160 "
                "-68.705 -80.858\n")
            c = foxsdock.app.test_client()
            rv = c.get('/job/testjob4/fit2?passwd=%s' % j.passwd)
            r = re.compile(
                    rb'docking_2 Fit to experimental profile.*'
                    rb'docking_2_iq\.png.*docking_2_iq\.dat.*'
                    rb'Experimental profile fit file.*'
                    rb'\&chi;<sup>2</sup> = 28.2913 c<sub>1</sub> = 1.05 '
                    rb'c<sub>2</sub> = 4',
                    re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)

    def test_get_model_fit_no_pdb(self):
        """Test get_model_fit_page, with no PDB"""
        with saliweb.test.make_frontend_job('testjob5') as j:
            make_input_txt(j)
            j.make_file("foxs_2.log", """
1abc.pdb saxs.dat Chi^2 = 28.2913 c1 = 1.05 c2 = 4 default chi^2 = 45.8281""")
            j.make_file("results_saxs.txt")
            c = foxsdock.app.test_client()
            rv = c.get('/job/testjob5/fit2?passwd=%s' % j.passwd)
            self.assertEqual(rv.status_code, 404)

    def test_get_model_pdb(self):
        """Test get_model_pdb, with PDB"""
        with saliweb.test.make_frontend_job('testjob6') as j:
            make_input_txt(j)
            j.make_file("docking_2.pdb", "foobar")
            j.make_file(
                "results_saxs.txt",
                "receptorPdb Str 5_new.pdb\n"
                "ligandPdb Str ICAM_Btype.pdb\n"
                "     # |  Score  | filt| ZScore |  SAXS  | Zscore "
                "|  SOAP     | Zscore | Transformation\n"
                "     1 |  -3.559 |  +  | -2.503 |  2.147 | -1.055 "
                "| -1610.932 | -2.504 |  -1.636 -0.108 0.361 -40.146 "
                "-84.326 -72.529\n"
                "     2 |  -3.461 |  +  | -2.434 |  1.812 | -1.292 "
                "| -1429.678 | -2.169 |  -1.357 0.112 0.608 -29.160 "
                "-68.705 -80.858\n")
            c = foxsdock.app.test_client()
            rv = c.get('/job/testjob6/result2.pdb?passwd=%s' % j.passwd)
            self.assertEqual(rv.data, b'foobar')

    def test_get_model_pdb_no_pdb(self):
        """Test get_model_pdb, with no PDB"""
        with saliweb.test.make_frontend_job('testjob7') as j:
            make_input_txt(j)
            j.make_file("results_saxs.txt")
            c = foxsdock.app.test_client()
            rv = c.get('/job/testjob7/result2.pdb?passwd=%s' % j.passwd)
            self.assertEqual(rv.status_code, 404)

    def test_get_foxs_fit_ok(self):
        """Test get_foxs_fit() with OK output"""
        with tempfile.TemporaryDirectory() as tmpdir:
            j = MockJob(tmpdir)
            foxs = j.make_exe(
                'foxs', '#!/bin/sh\necho Chi^2 = 1.0 c1 = 2.0 c2 = 3.0\n')
            gnuplot = j.make_exe('gnuplot', '#!/bin/sh\n')
            config = {'FOXSDOCK_FOXS': foxs,
                      'FOXSDOCK_GNUPLOT': gnuplot}
            chi, c1, c2 = foxsdock.results_page.get_foxs_fit(
                    j, 'test.pdb', 'test.profile', 1, config)
        self.assertEqual(chi, '1.0')
        self.assertEqual(c1, '2.0')
        self.assertEqual(c2, '3.0')

    def test_get_foxs_fit_bad(self):
        """Test get_foxs_fit() with no output"""
        with tempfile.TemporaryDirectory() as tmpdir:
            j = MockJob(tmpdir)
            foxs = j.make_exe('foxs', '#!/bin/sh\n')
            gnuplot = j.make_exe('gnuplot', '#!/bin/sh\n')
            config = {'FOXSDOCK_FOXS': foxs,
                      'FOXSDOCK_GNUPLOT': gnuplot}
            r = foxsdock.results_page.get_foxs_fit(
                    j, 'test.pdb', 'test.profile', 1, config)
        self.assertIsNone(r)

    def test_apply_trans(self):
        """Test apply_trans()"""
        with tempfile.TemporaryDirectory() as tmpdir:
            j = MockJob(tmpdir)
            j.make_file('receptor.pdb', 'test receptor\n')
            j.make_file('ligand.pdb', 'test ligand\n')
            pdb_trans = j.make_exe('pdb_trans',
                                   '#!/bin/sh\necho pdb_trans ran ok $*\n')
            config = {'FOXSDOCK_PDB_TRANS': pdb_trans}
            r = foxsdock.results_page.apply_trans(
                    j, 'receptor.pdb', 'ligand.pdb', 42, 'tran1 tran2', config)
            with open(j.get_path('docking_42.pdb')) as fh:
                contents = fh.read()
        self.assertEqual(r, 'docking_42.pdb')
        self.assertEqual(contents,
                         "test receptor\npdb_trans ran ok tran1 tran2\n")


if __name__ == '__main__':
    unittest.main()
