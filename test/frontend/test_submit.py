import unittest
import saliweb.test
import os
import re

# Import the foxsdock frontend with mocks
foxsdock = saliweb.test.import_mocked_frontend("foxsdock", __file__,
                                               '../../frontend')


class Tests(saliweb.test.TestCase):
    """Check submit page"""

    def test_submit_page(self):
        """Test submit page"""
        with saliweb.test.temporary_directory() as tmpdir:
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


if __name__ == '__main__':
    unittest.main()
