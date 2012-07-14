get:
	cp --no-preserve=ownership --recursive --update /home/rawdog/* -f .
	rm *.html feeds* state errors
	cp -f /etc/cron.d/rawdog crontab
	mrclean

