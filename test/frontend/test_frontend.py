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
        self.assertIn(b'Weighted SAXS scoring', rv.data)

    def test_about(self):
        """Test about page"""
        c = foxsdock.app.test_client()
        rv = c.get('/about')
        self.assertIn(b'method for docking with SAXS', rv.data)

    def test_help(self):
        """Test help page"""
        c = foxsdock.app.test_client()
        rv = c.get('/help')
        self.assertIn(b'output of FoXSDock is a list of complex models',
                      rv.data)

    def test_download(self):
        """Test download page"""
        c = foxsdock.app.test_client()
        rv = c.get('/download')
        self.assertIn(b'FoXSDock web server is a simple frontend',
                      rv.data)

    def test_links(self):
        """Test links page"""
        c = foxsdock.app.test_client()
        rv = c.get('/links')
        self.assertIn(b'open access SAXS database', rv.data)

    def test_queue(self):
        """Test queue page"""
        c = foxsdock.app.test_client()
        rv = c.get('/job')
        self.assertIn(b'No pending or running jobs', rv.data)


if __name__ == '__main__':
    unittest.main()
