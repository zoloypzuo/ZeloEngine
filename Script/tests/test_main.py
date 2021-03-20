import unittest

from framework.zmain import main


class TestMain(unittest.TestCase):
    def test_main(self):
        main()


if __name__ == '__main__':
    unittest.main()
