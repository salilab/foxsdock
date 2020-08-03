import unittest
import saliweb.test

# Import the foxsdock frontend with mocks
foxsdock = saliweb.test.import_mocked_frontend("foxsdock", __file__,
                                               '../../frontend')


class Tests(saliweb.test.TestCase):

    def test_index(self):
        """Test index page"""
        c = foxsdock.app.test_client()
        rv = c.get('/')
        self.assertIn(b'Experimental profile units', rv.data)

    def test_about(self):
        """Test about page"""
        c = foxsdock.app.test_client()
        rv = c.get('/about')
        self.assertIn(b'MultiFoXS is a method for multi-state modeling',
                      rv.data)

    def test_help(self):
        """Test help page"""
        c = foxsdock.app.test_client()
        rv = c.get('/help')
        self.assertIn(b'list of residues that their backbone phi and psi',
                      rv.data)

    def test_download(self):
        """Test download page"""
        c = foxsdock.app.test_client()
        rv = c.get('/download')
        self.assertIn(b'Computation of SAXS profiles', rv.data)

    def test_links(self):
        """Test links page"""
        c = foxsdock.app.test_client()
        rv = c.get('/links')
        self.assertIn(b'Please address inquiries to', rv.data)

    def test_queue(self):
        """Test queue page"""
        c = foxsdock.app.test_client()
        rv = c.get('/job')
        self.assertIn(b'No pending or running jobs', rv.data)


if __name__ == '__main__':
    unittest.main()
