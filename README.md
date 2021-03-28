Covid19 Situation in Outaouais
================

-   [Outaouais region totals](#outaouais-region-totals)
    -   [Average increase](#average-increase)
    -   [Cumulative cases](#cumulative-cases)
    -   [opencovid.ca](#opencovidca)
    -   [Active cases & testing &
        deaths](#active-cases--testing--deaths)
-   [Average increase by RLS](#average-increase-by-rls)
    -   [Gatineau](#gatineau)
    -   [Collines & Pontiac](#collines--pontiac)
    -   [Papineau & Vallée](#papineau--vallée)
-   [Active cases by RLS](#active-cases-by-rls)
    -   [Gatineau](#gatineau-1)
    -   [Collines & Pontiac](#collines--pontiac-1)
    -   [Papineau & Vallée](#papineau--vallée-1)
-   [Cumulative cases by RLS &
    municipality](#cumulative-cases-by-rls--municipality)
    -   [RLS](#rls)
    -   [Total & Gatineau](#total--gatineau)
    -   [Collines](#collines)
    -   [Papineau](#papineau)
    -   [Papineau (cont.)](#papineau-cont)
    -   [Vallée](#vallée)
    -   [Vallée (cont.)](#vallée-cont)
    -   [Pontiac](#pontiac)
-   [Glossary](#glossary)
-   [Method and caveats](#method-and-caveats)

It is difficult to find covid19 trend data over time at the local level
for the Outaouais region. The [Quebec
government](https://www.quebec.ca/en/health/health-issues/a-z/2019-coronavirus/situation-coronavirus-in-quebec/)
shows summaries but only the last few days of trends for regions.
[Quebec Public Health](https://www.inspq.qc.ca/covid-19/donnees) shows
longer time series but only cumulative snapshots by region. The
[COVID-19 Canada Open Data Working Group
(opencovid.ca)](https://opencovid.ca/) collects official time series
data at the individual, provincial and health region levels. None of
these sources provide trend data below the regional level. [CISSS
Outaouais](https://cisss-outaouais.gouv.qc.ca/language/en/covid19-en/)
provides frequent (sometimes daily) snapshots by Réseaux locaux de
services (RLS) and by municipality, but no trends. The present project
provides local trend data based on these snapshots. Please note
important caveats and data limitations at the bottom of this page.

**Note**: If the figures below do not show the latest data, reload this
page in your web browser.

## Outaouais region totals

### Average increase

<img src="README_files/figure-gfm/cases_avg-1.png" width="100%" height="100%" />

### Cumulative cases

<img src="README_files/figure-gfm/cases_cumulative-1.png" width="100%" height="100%" />

### opencovid.ca

<img src="README_files/figure-gfm/cases_opencovid-1.png" width="100%" height="100%" />

### Active cases & testing & deaths

<img src="README_files/figure-gfm/cases_other-1.png" width="100%" height="100%" />

## Average increase by RLS

### Gatineau

<img src="README_files/figure-gfm/rls_new_gatineau-1.png" width="100%" height="100%" />

### Collines & Pontiac

<img src="README_files/figure-gfm/rls_new_collines-1.png" width="100%" height="100%" />

### Papineau & Vallée

<img src="README_files/figure-gfm/rls_new_vallee-1.png" width="100%" height="100%" />

## Active cases by RLS

### Gatineau

<img src="README_files/figure-gfm/rls_active_gatineau-1.png" width="100%" height="100%" />

### Collines & Pontiac

<img src="README_files/figure-gfm/rls_active_collines-1.png" width="100%" height="100%" />

### Papineau & Vallée

<img src="README_files/figure-gfm/rls_active_vallee-1.png" width="100%" height="100%" />

## Cumulative cases by RLS & municipality

### RLS

<img src="README_files/figure-gfm/rls_cumulative-1.png" width="100%" height="100%" />

### Total & Gatineau

<img src="README_files/figure-gfm/areas_gatineau-1.png" width="100%" height="100%" />

### Collines

<img src="README_files/figure-gfm/areas_collines-1.png" width="100%" height="100%" />

### Papineau

<img src="README_files/figure-gfm/areas_papineau-1.png" width="100%" height="100%" />

### Papineau (cont.)

<img src="README_files/figure-gfm/areas_papineau_cont-1.png" width="100%" height="100%" />

### Vallée

<img src="README_files/figure-gfm/areas_papineau_vallee-1.png" width="100%" height="100%" />

### Vallée (cont.)

<img src="README_files/figure-gfm/areas_papineau_vallee_cont-1.png" width="100%" height="100%" />

### Pontiac

<img src="README_files/figure-gfm/areas_pontiac-1.png" width="100%" height="100%" />

## Glossary

| Indicators                      | Description                                                                                            |
|---------------------------------|--------------------------------------------------------------------------------------------------------|
| Total cases                     | reported total number of cases of infections to date, aggregated at regional, RLS or municipal level   |
| Active cases                    | total number minus numbers of deaths and healed or resolved cases, aggregated at regional or RLS level |
| Healed / resolved cases         | reported number of resolved cases at regional level                                                    |
| Average increase per day        | average daily increase over last 7 days, calculated from available data                                |
| Total deaths                    | reported total number of deaths at the regional level                                                  |
| Average screening tests per day | reported average daily number of covid19 tests performed over last 6-7 days                            |

<!-- | New cases / daily increase      | newly reported cases at the regional level                                                             | -->

## Method and caveats

The HTML source for the [CISSS Outaouais
site](https://cisss-outaouais.gouv.qc.ca/language/en/covid19-en/) is
downloaded daily, the tables are scraped and processed into a tidy
dataset, to produce the figures on this site. The
[opencovid.ca](https://opencovid.ca/) health region data are included
for comparison. The R code for downloading and processing the data is
available in this repository. (Daily automation is currently done with
MacScheduler.)

Users of these data need to be aware of the following caveats:

1.  There is no guarantee of data accuracy. I am aggregating what CISSS
    Outaouais has been reporting over time. While I do try to correct
    obvious data input error, I have (so far) not implemented an
    automatic error detection process.

2.  The date and time in the dataset refer to when the CISSS Outaouais
    website was accessed, not when cases occurred.

3.  The trend data are not complete (i.e daily) for several reasons.
    First, I started regularly downloading the CISSS Outaouais source in
    fall 2020, and used the [Wayback Machine](https://archive.org/web/)
    to get earlier snapshots. Unfortunately, due to a nasty syncing
    glitch, I lost some HTML source files. (RStudio projects and Dropbox
    do not play well together; I learnt this the hard way, twice.)
    Second, the CISSS Outaouais site is not updated every day. Third,
    running the code from my personal computer means that the automatic
    download does not happen every day, either because the computer is
    turned off, or because my software for scheduling scripts has failed
    a few times. Since the snapshots include cumulative counts, this is
    not necessarily a problem, but it means that changes in case counts
    cannot always be precisely dated.

4.  Not all the data available on the CISSS Outaouais site are currently
    included in the dataset.

5.  Over time, CISSS Outaouais has made changes to what it reports and
    how it labels indicators. While I fix some inconsistencies in
    labels, I do not reconcile closely related indicators. The figures
    show how reporting by CISSS Outaouais has changed.

6.  At the municipal and RLS levels, CISSS Outaouais does not report
    numbers of less than 6 precisely, likely for good privacy reasons.
    When “5 or less” are reported, I record this as 5 cases. Users of
    this dataset must be aware that counts of 5 do not precisely reflect
    the actual situation at those levels, but refer to 1-5 cases.

Questions, concerns, and suggestions can be raised through GitHub
Discussions.

Last HTML source download: 2021-03-27 22:54:36

Last dataset revision: 2021-03-27 22:55:06

Page revised: 2021-03-27 22:55:57
