# IAC-Team-12
## Essential Commands
### First Time setting up:
Use the the following command to clone this git repo:
```
git clone git@github.com:Abeeekoala/IAC-Team-12.git
```
Then, checkout the branch we are currently working on:
```
git checkout
```
This should display `Your branch is up to date with 'origin/main'.`
To switch to the branch we want to work on, for example `origin/Abraham`, we could
```
git checkout Abraham
```
This will show `Switched to a new branch 'Abraham'` We are now working on the desired branch!

### Whenever we want to commit:
To check which branch we are working at:
```
git branch -vv
```
Make sure this returns the branch we want to push to.
Check the status of the beanch by
```
git fetch
```
Then,
```
git status
```
If your branch is behind, git status will show a message like:
```
Your branch is behind 'origin/XXX' by X commits, and can be fast-forwarded.
```
We can then use the following to fast-forward
```
git pull --ff-only
```
If there is an Error in merging the remote branch, we need to handle the merge manually.

Now we can add the files to be commit either by specific file name or simply `add .`
```
git add .
```
And then add the message for the commit.
```
git commit -m "commit messsage"
```

And finally push to the branch by
```
git push
```

### When we need to update the commits from the main branch
Go onto Github website and create a pull request on your branch (from main to your banch) then if able to merge, you can get the updates. 


### When you need to merge your branch to the main
Navigate to your branch on github website, there should be a Compare & pull request button. \n
Click it, you should see the form to create a pull request by adding title and description of the pull request. \n
And right above title, if it said `Able to merge`, it will generally be fine, if not you need to review the commits below to see if there are commits in the main branch that are not up to date to your branch. If that is the case merge from the main branch before mahing pull request.
