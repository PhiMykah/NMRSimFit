from setuptools import setup, Extension
from Cython.Build import cythonize

extensions = [
    Extension("simfit.hello", ["simfit/hello.pyx"]) 
]

setup(
    name='NMR SimFit',
    version="0.0.1",
    description="A general-purpose spectral fitting tool",
    ext_modules=cythonize(extensions, language_level = "3"),
    entry_points={
        'console_scripts': [
            'simfit=simfit.main:main',
        ],
    }
)

# script_args=['build_ext', '--inplace']