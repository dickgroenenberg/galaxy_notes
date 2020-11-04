#!/bin/bash

#------------------------------------------------------------------------------------------------------
# This script is intended to be used with cron.
# It will invoke the cleanup scripts (/home/galaxy/galaxy/scripts/cleanup_datasets/) that come with
# Galaxy (v.19.09):
# cleanup_datasets.py		- interacts with galaxydb using galaxy / python
# pgcleanup.py				- interacts with galaxydb using postgres (psql)
#
# Galaxy could be maintened with either script, but both have their own advances (i.e. cleanup_datasets.py
# has a convenient way of notifying users of dataset deletions, whereas pgcleanup.py has better performance
# specs. This script will run both scripts sequentially with the number of days parameter set to 60 and 74
# (-d and -0) for the first and second script, respectively. The logic behind this is that pgcleanup.py will
# deal with datasets that for some reason have been missed by cleanup_datasets.py.
#
# To set up cron: crontab -e
#
# A 'crontab generator' can be used to set up a cron job (https://crontab-generator.org)
# Here's an example how to run this script every night at 3 am:
# 0 3 * * * sh /home/galaxy/galaxy/cron/Naturalis_cron.sh
#
# Although each user can set up cronjobs for their accounts (given that no restrictions have been
# defined in /etc/cron.allow or /etc/cron.deny); the cron daemon can only be activated as root:
# sudo service cron start		# stop / restart
#
#------------------------------------------------------------------------------------------------------

# if non-existing create log-folders:
mkdir -p /home/galaxy/Log/cleanup /home/galaxy/Log/pgcleanup

#------------------------------------------------------------------------------------------------------#
# cleanup_datasets.py                                                                                  #
#------------------------------------------------------------------------------------------------------#

# Adding galaxy.yml is required (it specifies the location of the main galaxy database)
# Use -r to actually remove the data, use -i to show what will happen without actually removing the data
python /home/galaxy/galaxy/scripts/cleanup_datasets/admin_cleanup_datasets.py -d 60 /home/galaxy/galaxy/config/galaxy.yml &>> /home/galaxy/Log/cleanup/0.admin_cleanup_dataset.log
# Note that -3 has been set before -6, because datasets can only be deleted only after perge
python /home/galaxy/galaxy/scripts/cleanup_datasets/cleanup_datasets.py -d 60 -1 -r /home/galaxy/galaxy/config/galaxy.yml &>> /home/galaxy/Log/cleanup/1.delete_userless_histories.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/cleanup_datasets.py -d 60 -2 -r /home/galaxy/galaxy/config/galaxy.yml &>> /home/galaxy/Log/cleanup/2.purge_histories.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/cleanup_datasets.py -d 60 -3 -r /home/galaxy/galaxy/config/galaxy.yml &>> /home/galaxy/Log/cleanup/3.purge_datasets.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/cleanup_datasets.py -d 60 -4 -r /home/galaxy/galaxy/config/galaxy.yml &>> /home/galaxy/Log/cleanup/4.purge_libraries.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/cleanup_datasets.py -d 60 -5 -r /home/galaxy/galaxy/config/galaxy.yml &>> /home/galaxy/Log/cleanup/5.purge_folders.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/cleanup_datasets.py -d 60 -6 -r /home/galaxy/galaxy/config/galaxy.yml &>> /home/galaxy/Log/cleanup/6.delete_datasets.log


#------------------------------------------------------------------------------------------------------#
# pgcleanup.py                                                                                         #
#------------------------------------------------------------------------------------------------------#

# -l should generate a log file, but did not do so on Test; as cleanup_datasets.py is setup to run two
# weeks in advent - log files for pgcleanup are expected to contain little information.
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup delete_datasets &>> /home/galaxy/Log/pgcleanup/01.delete_datasets.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup delete_exported_histories &>> /home/galaxy/Log/pgcleanup/02.delete_exported_histories.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup delete_inactive_users &>> /home/galaxy/Log/pgcleanup/03.delete_inactive_users.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup delete_userless_histories &>> /home/galaxy/Log/pgcleanup/04.delete_userless_histories.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup purge_datasets &>> /home/galaxy/Log/pgcleanup/05.purge_datasets.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup purge_deleted_hdas &>> /home/galaxy/Log/pgcleanup/06.purge_deleted_hdas.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup purge_deleted_histories &>> /home/galaxy/Log/pgcleanup/07.purge_deleted_histories.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup purge_deleted_users &>> /home/galaxy/Log/pgcleanup/08.purge_deleted_users.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup purge_error_hdas &>> /home/galaxy/Log/pgcleanup/09.purge_error_hdas.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup purge_hdas_of_purged_histories &>> /home/galaxy/Log/pgcleanup/10.purge_hdas_of_purged_histories.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup purge_historyless_hdas &>> /home/galaxy/Log/pgcleanup/11.purge_historyless_hdas.log
python /home/galaxy/galaxy/scripts/cleanup_datasets/pgcleanup.py -o 60 -c /home/galaxy/galaxy/config/galaxy.yml -l /home/galaxy/Log/pgcleanup update_hda_purged_flag &>> /home/galaxy/Log/pgcleanup/12.update_hda_purged_flag.log

# shouldn't /home/galaxy/galaxy/database/tmp be cleaned regularly ??!
#

deactivate



