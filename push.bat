@echo off
set /p msg="Commit message: "
git rm -r --cached
git add .
git commit -m "%msg%"
git push