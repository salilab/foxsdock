import unittest
import foxsdock
import saliweb.test
import os

class Tests(saliweb.test.TestCase):

    def test_postprocess_ok(self):
        """Test postprocess with everything OK"""
        j = self.make_test_job(foxsdock.Job, 'RUNNING')
        d = saliweb.test.RunInDir(j.directory)
        with open('foxsdock.log', 'w') as fh:
            fh.write("everything ok\n")
        j.postprocess()

    def test_postprocess_bad_log(self):
        """Test postprocess with bad log file"""
        j = self.make_test_job(foxsdock.Job, 'RUNNING')
        d = saliweb.test.RunInDir(j.directory)
        for err in ("Can't find library file: ./chem.lib\n",
                    "cut: clustered_saxs.res: No such file or directory\n"):
            with open('foxsdock.log', 'w') as fh:
                fh.write(err)
            self.assertRaises(foxsdock.LogError, j.postprocess)

if __name__ == '__main__':
    unittest.main()
