## Method & Caveats

The HTML source for the [CISSS Outaouais site](https://cisss-outaouais.gouv.qc.ca/language/en/covid19-en/) is accessed daily, the tables are scraped and processed into a tidy dataset, to produce the local figures on this site. For the regional and RLS levels, various official datasets are downloaded daily from Quebec government and INSPQ sites. Some historical hospitalization data come from the [Ministère de la Santé et des Services sociaux (MSSS)](https://www.donneesquebec.ca/recherche/dataset/covid-19-portrait-quotidien-des-hospitalisations). The latest [opencovid.ca](https://opencovid.ca/) health region data are included for comparison. The source code for downloading and processing all data, and the resulting datasets, are available in the project [GitHub repository](https://github.com/timothoms/covid19Outaouais). Daily automation is currently done with MacScheduler.

Users of the CISSS Outaouais (local) data need to be aware of the following caveats:

1. There is no guarantee of data accuracy. I am aggregating what CISSS Outaouais has been reporting over time. While I do try to correct obvious data input error, I have (so far) not implemented an automatic error detection process.

2. The date and time in the dataset refer to when the CISSS Outaouais page was accessed, not when cases occurred.

3. The trend data are not complete (i.e daily) for several reasons. First, I started regularly downloading the CISSS Outaouais source in fall 2020, and used the [Wayback Machine](https://archive.org/web/) to get earlier snapshots. Unfortunately, due to a nasty syncing glitch, I lost some HTML source files. (RStudio projects and Dropbox do not play well together; I learnt this the hard way, twice.) Second, the CISSS Outaouais site is not updated every day. Third, running the code from my personal computer means that the automatic download does not happen every day, either because the computer is turned off, or because my software for scheduling scripts has failed a few times. Since the snapshots include cumulative counts, this is not necessarily a problem, but it means that changes in local case counts cannot always be precisely dated. In the figures of local data, "rugs" indicate dates for which the data are available.

<!-- 5. Over time, CISSS Outaouais has made changes to what it reports and how it labels indicators. While I fix some inconsistencies in labels, I do not reconcile closely related indicators. The figures show how reporting by CISSS Outaouais has changed (i.e when certain indicator are, or are not, reported). -->

<!-- 6. At the municipal and RLS levels,  -->
4. At the local level, CISSS Outaouais does not report numbers of less than 6 precisely, likely for good privacy reasons. When "5 or less" are reported, I record this as 5 cases. Users of this dataset must be aware that counts of 5 do not precisely reflect the actual situation at those levels, but refer to 1-5 cases.

Further: 

5. Expressing vaccination doses as a percentage of the Outaouais population (in 2020) assumes that receivers of the vaccine are Outaouais residents **and** that they have received one dose only. These strong assumptions may be reasonable early in the vaccination campaign, but less so as time progresses.
