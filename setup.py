from setuptools import setup, Extension, find_packages
from Cython.Build import cythonize
import numpy

extensions = [
    Extension("simfit.simulate", ["simfit/simulate.pyx"], include_dirs=[numpy.get_include()])
]

setup(
    name='NMRSimFit',
    packages=find_packages(),
    version="0.1.0",
    description="A general-purpose spectral fitting tool",
    ext_modules=cythonize(extensions, language_level = "3"),
    entry_points={
        'console_scripts': [
            'simfit=simfit.main:main',
        ],
    }
)

# script_args=['build_ext', '--inplace']