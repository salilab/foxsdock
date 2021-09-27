import unittest
import saliweb.test
import tempfile
import os
import re

# Import the foxsdock frontend with mocks
foxsdock = saliweb.test.import_mocked_frontend("foxsdock", __file__,
                                               '../../frontend')


class Tests(saliweb.test.TestCase):
    """Check submit page"""

    def test_submit_page(self):
        """Test submit page"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            foxsdock.app.config['DIRECTORIES_INCOMING'] = incoming
            c = foxsdock.app.test_client()

            data = {}
            # Invalid complex type
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'Error in the types of molecules', rv.data)

            pdbf = os.path.join(tmpdir, 'test.pdb')
            with open(pdbf, 'w') as fh:
                fh.write(
                    "REMARK\n"
                    "ATOM      2  CA  ALA     1      26.711  14.576   5.091\n")

            saxsf = os.path.join(tmpdir, 'test.profile')
            with open(saxsf, 'w') as fh:
                fh.write("0.00000    9656627.00000000 2027.89172363\n")

            # No profile uploaded
            data = {'moltype': 'Default', 'jobname': 'foobar',
                    'recfile': open(pdbf, 'rb'), 'ligfile': open(pdbf, 'rb')}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'No SAXS profile uploaded!', rv.data)

            # Successful submission (no email)
            data = {'moltype': 'Default', 'jobname': 'foobar',
                    'recfile': open(pdbf, 'rb'), 'ligfile': open(pdbf, 'rb'),
                    'saxsfile': open(saxsf, 'rb')}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 200)
            r = re.compile(b'Your job <b>foobar</b> has been submitted.*'
                           b'Results will be found at',
                           re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)

            # Make sure data.txt and input.txt are generated
            with open(os.path.join(incoming, 'foobar', 'data.txt')) as fh:
                contents = fh.read()
            self.assertEqual(
                contents,
                "test.pdb test.pdb --saxs test.profile "
                "--complex_type Default None\n")
            with open(os.path.join(incoming, 'foobar', 'input.txt')) as fh:
                contents = fh.read()
            self.assertEqual(
                contents,
                "test.pdb test.pdb --saxs test.profile "
                "--complex_type Default\n")

            # Successful submission (with email)
            data = {'moltype': 'Default', 'email': 'test@example.com',
                    'recfile': open(pdbf, 'rb'), 'ligfile': open(pdbf, 'rb'),
                    'saxsfile': open(saxsf, 'rb')}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 200)
            r = re.compile(rb'Your job <b>job\S*</b> has been submitted.*'
                           b'Results will be found at.*'
                           b'You will be notified at test@example.com when',
                           re.MULTILINE | re.DOTALL)
            self.assertRegex(rv.data, r)

    def test_submit_weighted(self):
        """Test submit with weighted SAXS score option"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            foxsdock.app.config['DIRECTORIES_INCOMING'] = incoming
            c = foxsdock.app.test_client()

            data = {}
            pdbf = os.path.join(tmpdir, 'test.pdb')
            with open(pdbf, 'w') as fh:
                fh.write("foo")

            saxsf = os.path.join(tmpdir, 'test.profile')
            with open(saxsf, 'w') as fh:
                fh.write("0.00000    9656627.00000000 2027.89172363\n")

            data = {'moltype': 'Default', 'jobname': 'foobar',
                    'weighted': 'on',
                    'recfile': open(pdbf, 'rb'), 'ligfile': open(pdbf, 'rb'),
                    'saxsfile': open(saxsf, 'rb')}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 200)

            with open(os.path.join(incoming, 'foobar', 'input.txt')) as fh:
                contents = fh.read()
            self.assertEqual(
                contents,
                "test.pdb test.pdb --saxs test.profile "
                "--complex_type Default --weighted_saxs_score\n")

    def test_submit_empty_profile(self):
        """Test submit with empty profile"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            foxsdock.app.config['DIRECTORIES_INCOMING'] = incoming
            c = foxsdock.app.test_client()

            data = {}
            pdbf = os.path.join(tmpdir, 'test.pdb')
            with open(pdbf, 'w') as fh:
                fh.write("foo")

            saxsf = os.path.join(tmpdir, 'test.profile')
            with open(saxsf, 'w') as fh:
                pass

            data = {'moltype': 'Default', 'jobname': 'foobar',
                    'recfile': open(pdbf, 'rb'), 'ligfile': open(pdbf, 'rb'),
                    'saxsfile': open(saxsf, 'rb')}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'You have uploaded an empty SAXS profile file',
                          rv.data)

    def test_submit_empty_pdb(self):
        """Test submit with empty PDB"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            foxsdock.app.config['DIRECTORIES_INCOMING'] = incoming
            c = foxsdock.app.test_client()

            data = {}
            pdbf = os.path.join(tmpdir, 'test.pdb')
            with open(pdbf, 'w') as fh:
                pass

            saxsf = os.path.join(tmpdir, 'test.profile')
            with open(saxsf, 'w') as fh:
                fh.write("foo")

            data = {'moltype': 'Default', 'jobname': 'foobar',
                    'recfile': open(pdbf, 'rb'), 'ligfile': open(pdbf, 'rb'),
                    'saxsfile': open(saxsf, 'rb')}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'You have uploaded an empty receptor PDB file',
                          rv.data)

    def test_submit_pdb_code(self):
        """Test submit with a PDB code"""
        with tempfile.TemporaryDirectory() as tmpdir:
            with tempfile.TemporaryDirectory() as pdb_root:
                foxsdock.app.config['DIRECTORIES_INCOMING'] = tmpdir
                foxsdock.app.config['PDB_ROOT'] = pdb_root
                os.mkdir(os.path.join(pdb_root, 'ab'))
                os.mkdir(os.path.join(pdb_root, 'xy'))
                with open(os.path.join(pdb_root, 'ab', 'pdb1abc.ent.gz'), 'w'):
                    pass
                with open(os.path.join(pdb_root, 'xy', 'pdb2xyz.ent.gz'), 'w'):
                    pass

                c = foxsdock.app.test_client()

                data = {}
                saxsf = os.path.join(tmpdir, 'test.profile')
                with open(saxsf, 'w') as fh:
                    fh.write("foo")

                data = {'moltype': 'Default', 'jobname': 'foobar',
                        'receptor': '1abc', 'ligand': '2xyz',
                        'saxsfile': open(saxsf, 'rb')}
                rv = c.post('/job', data=data)
                self.assertEqual(rv.status_code, 200)

    def test_submit_no_pdb(self):
        """Test submit with no PDB"""
        with tempfile.TemporaryDirectory() as tmpdir:
            incoming = os.path.join(tmpdir, 'incoming')
            os.mkdir(incoming)
            foxsdock.app.config['DIRECTORIES_INCOMING'] = incoming

            c = foxsdock.app.test_client()

            data = {}
            saxsf = os.path.join(tmpdir, 'test.profile')
            with open(saxsf, 'w') as fh:
                fh.write("foo")

            data = {'moltype': 'Default', 'jobname': 'foobar',
                    'saxsfile': open(saxsf, 'rb')}
            rv = c.post('/job', data=data)
            self.assertEqual(rv.status_code, 400)
            self.assertIn(b'specify PDB code or upload file for receptor',
                          rv.data)


if __name__ == '__main__':
    unittest.main()
