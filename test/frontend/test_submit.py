import unittest
import saliweb.test
import os
import re
from werkzeug.datastructures import FileStorage

# Import the foxsdock frontend with mocks
foxsdock = saliweb.test.import_mocked_frontend("foxsdock", __file__,
                                                '../../frontend')


class Tests(saliweb.test.TestCase):
    """Check submit page"""

    def test_submit_page(self):
        """Test submit page"""
        incoming = saliweb.test.TempDir()
        foxsdock.app.config['DIRECTORIES_INCOMING'] = incoming.tmpdir
        c = foxsdock.app.test_client()

        data = {}
        # Invalid complex type
        rv = c.post('/job', data=data)
        self.assertEqual(rv.status_code, 400)
        self.assertIn(b'Error in the types of molecules', rv.data)

        t = saliweb.test.TempDir()
        pdbf = os.path.join(t.tmpdir, 'test.pdb')
        with open(pdbf, 'w') as fh:
            fh.write("REMARK\n"
                     "ATOM      2  CA  ALA     1      26.711  14.576   5.091\n")

        saxsf = os.path.join(t.tmpdir, 'test.profile')
        with open(saxsf, 'w') as fh:
            fh.write("0.00000    9656627.00000000 2027.89172363\n")

        # Successful submission (no email)
        data = {'moltype': 'Default', 'jobname': 'foobar',
                'recfile': open(pdbf, 'rb'), 'ligfile': open(pdbf, 'rb')}
        rv = c.post('/job', data=data)
        self.assertEqual(rv.status_code, 200)
        r = re.compile(b'Your job <b>foobar</b> has been submitted.*'
                       b'Results will be found at',
                       re.MULTILINE | re.DOTALL)
        self.assertRegex(rv.data, r)

        # Make sure data.txt and input.txt are generated
        with open(os.path.join(incoming.tmpdir, 'foobar', 'data.txt')) as fh:
            contents = fh.read()
        self.assertEqual(contents,
                "test.pdb test.pdb --saxs - --complex_type Default None\n")
        with open(os.path.join(incoming.tmpdir, 'foobar', 'input.txt')) as fh:
            contents = fh.read()
        self.assertEqual(contents,
                "test.pdb test.pdb --saxs - --complex_type Default\n")

        # Successful submission (with email)
        data = {'moltype': 'Default', 'email': 'test@example.com',
                'recfile': open(pdbf, 'rb'), 'ligfile': open(pdbf, 'rb')}
        rv = c.post('/job', data=data)
        self.assertEqual(rv.status_code, 200)
        r = re.compile(b'Your job <b>job\S*</b> has been submitted.*'
                       b'Results will be found at.*'
                       b'You will be notified at test@example.com when',
                       re.MULTILINE | re.DOTALL)
        self.assertRegex(rv.data, r)

if __name__ == '__main__':
    unittest.main()
