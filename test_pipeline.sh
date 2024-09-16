py_chk="$(pycodestyle --max-line-length=120 */*/*.py --ignore=E303,E123,E266,E128,E127)"
echo $py_chk
if [ ${#py_chk} -ne 0 ]; then
    exit 1
else
    echo "Successfully passed the test."
fi
