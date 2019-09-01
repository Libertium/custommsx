find . -depth -exec rename 's/(.*)\/([^\/]*)/$1\/\L$2/' {} \;
