# password_quality.sh

this script checks the quality of passwords based on a point system where the best you can reach are 5 points, 
in that case your password consists of at least 8 characters and contains lower letters, upper letters, numbers, special characters
and has maximum only one character duplication

## let's build a password
```
./password_quality.sh a
password is too short

./password_quality.sh aaaaaaaa
you reached 1 out of 5 possible points
things you can improve:
- don't use char duplication
- add upper letters
- add specialchars
- add integers

./password_quality.sh aaaaaaa1
you reached 2 out of 5 possible points
things you can improve:
- don't use char duplication
- add upper letters
- add specialchars

./password_quality.sh aaaaaaX1
you reached 3 out of 5 possible points
things you can improve:
- don't use char duplication
- add specialchars

./password_quality.sh aaaaa_X1
you reached 4 out of 5 possible points
things you can improve:
- don't use char duplication

./password_quality.sh Gh3Va_X1
congrats, there is nothing you can improve with your password
you reached 5 out of 5 possible points
```
