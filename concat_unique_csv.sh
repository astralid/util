# remove lines containing only ,\r\n
# then remove all ,
grep -v '^,^M$' Downloads/uutiskirjelista.csv | tr -d ',' > newsubs.csv

# remove from newsubs all lines present in email_subs
grep -Fvxf Downloads/email_subscribers.csv newsubs.csv > newuniqsubs.csv

# concatenate first line of email_subs AND all of newuniqsubs to uudet
cat <(head -1 Downloads/email_subscribers.csv) newuniqsubs.csv > uudet_tilaajat.csv
