import unittest
import foxsdock
import saliweb.test
import saliweb.backend
import os

class JobTests(saliweb.test.TestCase):
    """Check custom FoXSDock Job class"""

    def test_run_ok(self):
        """Test successful run method"""
        j = self.make_test_job(foxsdock.Job, 'RUNNING')
        j.config.script_directory = 'foo'
        with saliweb.test.working_directory(j.directory):
            open('input.txt', 'w').write('input line1\ninput line2\n')
            cls = j.run()
            self.assertIsInstance(cls, saliweb.backend.SGERunner)

    def test_complete(self):
        """Test complete() method"""
        j = self.make_test_job(foxsdock.Job, 'RUNNING')
        with saliweb.test.working_directory(j.directory):
            j.complete()

if __name__ == '__main__':
    unittest.main()
