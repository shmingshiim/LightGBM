function Check-Output {
  param( [bool]$success )
  if (!$success) {
    $host.SetShouldExit(-1)
    Exit -1
  }
}

$env:PATH += ";$env:CONDA_PREFIX\Library\bin\graphviz"  # temp graphviz hotfix

if ($env:TASK -eq "regular") {
  mkdir $env:BUILD_SOURCESDIRECTORY/build; cd $env:BUILD_SOURCESDIRECTORY/build
  cmake -A x64 .. ; cmake --build . --target ALL_BUILD --config Release ; Check-Output $?
  cd $env:BUILD_SOURCESDIRECTORY/python-package
  python setup.py install --precompile ; Check-Output $?
}

pip install catboost
cd $env:BUILD_SOURCESDIRECTORY/tests
python 2399.py ; Check-Output $?
