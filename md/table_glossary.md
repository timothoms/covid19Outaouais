## Glossary 

|                                  | Description |
|----------------------------------|-------------|
| Active cases                     | total number minus numbers of deaths and resolved cases, aggregated at regional or RLS level         |

the number of confirmed cases that have not recovered or have died. Active cases contribute to the spread of the disease in the population.

| Active hospitalizations          | reported active hospitalizations for confirmed covid-19 diagnosis                                    |

Current (active) hospitalizations

    Current hospitalizations correspond to the number of people currently in hospital with a diagnosis of COVID-19.
    Data on current hospitalizations includes regular hospitalizations and those in intensive care.
    The people who received their leave during the analysis day are counted.


| Average increase per day         | average daily increase in cases over last 7 days, calculated from available data                     |



The 7-day moving average corresponds to the average number of events (case or death) of the selected day, the 3 previous days and the 3 following days. It eliminates the fluctuations observed every day and emphasizes the longer-term trend.


| Average positive tests per day   | TBA                                                                                                  |
| Average testing per day          | reported average daily number of covid-19 tests performed over last 7 days                           |
| Average test positivity          | TBA                                                                                                  |

confirmed cases: Confirmed cases include laboratory confirmed cases and epidemiologically linked cases. A case confirmed by an epidemiological link corresponds to a person who has developed compatible symptoms while having had a high-risk exposure with a laboratory-confirmed case. Note that clinical cases are excluded from the data published on the INSPQ website.
About the graphics:

    The number of confirmed cases per day (depending on the reporting date) is reviewed daily and retroactively.

    The number of confirmed cases per day (according to the date of declaration) is always underestimated for the most recent days due to a delay between the moment of the declaration of the case and the entry of the information in the system. 'information. The days most affected by this delay are presented in a gray area.

Local service networks (RLS)

A masking is applied to the data of the RLS which have 1 to 4 cases.

The total of confirmed cases in a health region does not always equal the sum of cases in the RLS due to unknown values, entry errors or transfers between regions. We cannot therefore deduce the hidden numbers.


| Cumulative cases                 | TBA                                                                                                  |
| New cases                        | TBA                                                                                                  |
| New Hospitalizations             | TBA                                                                                                  |

Incidental hospitalizations (news)

    Incident hospitalizations correspond to the number of people newly admitted to the hospital.
    Data on incidental hospitalizations include regular hospitalizations and those in intensive care.
    Incident hospitalizations include all cases of COVID admitted to hospitals, whether confirmed (with primary diagnosis) or provisional (with secondary diagnosis). However, it is not possible to distinguish a patient hospitalized for COVID from a patient with COVID hospitalized for something else. Since the data is corrected daily, a patient's status could be changed based on new information about their hospitalization and would be adjusted retroactively. For example, a patient initially admitted with COVID could be removed from the system later.
    An inpatient who is first admitted to general care (excluding intensive care), then transferred to intensive care, will only be counted once and his date of admission will remain the same. The information will be adjusted retroactively.
    The hospitals considered are general and specialized care hospitals offering acute care.
    Hospitalizations are broken down according to the health region of the patient's residence and not according to the region where the hospital is located.

About the graphics:

    The number of incidental hospitalizations may be lower for the most recent days due to a delay in entering the information. The days most affected by this delay are presented in a gray area.
    The number of incidental hospitalizations by date of admission is revised daily and retroactively.
    
| Persons tested                   | TBA                                                                                                  |

People tested

The extraction of data from the laboratories is done the day before the release date at noon. The data in Chart 4.1 released on the web on November 3 at 11 a.m. are the cumulative data of test persons entered into the system until November 2 at noon.

    The number of people tested is the number of people who have had at least 1 sample for COVID-19 and who have obtained at least 1 negative or positive laboratory test result. Each person is represented only once.
    The number of disabled people corresponds to the number of people who have had at least 1 sample for COVID-19 and who have obtained at least 1 negative laboratory test result and no positive result. Only the first negative result is recorded. Each person is represented only once.
    The number of confirmed cases is the number of people with a positive laboratory test result. Only the first positive laboratory result of the first infectious episode of 90 days is counted (even if a 2nd episode occurs after 90 days).

About the chart:

    People waiting for a result are excluded from the total number of people tested. The data is revised daily and retroactively.
    The cumulative number of people tested excludes duplicates. For example:
        A person having tested negative several times (invalid person), and never positive, will be counted only once, according to the date of his first negative result.
        A person who has tested positive several times (confirmed case) will only be counted once in a 90-day period, depending on the date of their first positive result.
        A person who tested negative, then positive, will initially be included in the cumulative number of invalids, then will be transferred to confirmed cases. She will never again be counted as an invalid, even if she receives a negative result after her positive result. So a person who tests negative on 1 st November positive on 3 November, 10 November and negative still negative 2 March 2021:
            The 1 st and 2 November, it will be included in accumulated overturned people.
            On November 3, it will be removed from the cumulative number of disabled people and added to the cumulative number of confirmed cases.
            On November 10 and March 2, nothing changes, this person will still be included in the accumulation of confirmed cases and excluded from the accumulation of disabled people.

| Persons tested positive          | TBA                                                                                                  |
| Resolved/recovered cases         | reported number of resolved cases at regional level                                                  |



The criteria that allow a person to be considered “recovered” are determined by expert committees on the basis of scientific knowledge. A person is considered recovered when they meet the criteria for lifting isolation as described in the guide Measures for the management of cases and contacts in the community.(the link is external). These criteria are revised as needed, depending on the state of knowledge on the duration of the contagiousness of COVID. For example, from August 28, 2020, the lifting of isolation has been increased from 14 to 10 days for home cases and from 21 to 28 days for immunosuppressed cases.

The recovery status of a person is above all determined by the clinical teams or the public health departments who are responsible for updating the progress of the case in the information system.

However, since the progress status of the case is not always updated, an algorithm is applied to estimate the number of people who have recovered. People considered to have recovered are presumably no longer contributing to the transmission of the disease within the population. This operation is applied to the data on a daily basis and takes into account the adjustments made by the public health departments to the status of cases in the information system.
Rules of the algorithm for estimating the number of recovered cases

Reminder: Before applying the algorithm, the information of the “Restored” status of the “Evolution” variable of the information system is first used.
Exclusion from the calculation of reinstated

    Status "Deceased".
    Hospitalization in progress.

For all other cases (including healthcare workers), whose status is missing or "In progress", the following rules apply:
1. Non-hospitalized cases

    Application of a period of 10 days after the date of withdrawal.
    Exceptions: Application of a period of 28 days after the sample date for people aged 80 and over, residents in CHSLDs or people with an “immunosuppressed” risk factor.

2. Hospitalized cases outside intensive care with a date of discharge from hospital

The most recent of the following dates is used:

    Date of discharge from hospital.

OR

    10 days after the date of collection.
    28 days after the date of collection for people aged 80 and over, residents in CHSLDs or people with an “immunosuppressed” risk factor.

3. Intensive care hospitalized cases with a discharge date

The most recent of the following dates is used:

    Date of discharge from hospital.

OR

    21 days after the date of collection.
    28 days after the date of collection for people aged 80 and over, residents in CHSLDs or people with an “immunosuppressed” risk factor.

4. Inpatient cases (regular or intensive care) in progress without date of discharge

    Recovery 90 days after the sample date if the case is still hospitalized or if the hospital discharge date is missing.

Notes:

    When the debit date is absent, the declaration date is used.
    The old criteria for lifting isolation (14 days for cases at home and 21 days for immunosuppressed cases) have been maintained for cases whose collection date is prior to August 28, 2020.

    When a case is “Recovered” in the data system but the restore date is missing, then the algorithm is used to estimate that date.

| Test positivity                  | TBA                                                                                                  |

Percentage of positivity

The extraction of data from the laboratories is done at noon and covers the day preceding the date of extraction. Thus, the data in the graph is presented with a day of delay compared to other data disseminated on the web. For example, data webcast on November 3 at 11 am are those of the 1 st  November (taken at noon on November 2).

    A confirmed case is a person who has obtained a positive laboratory test result. Only the first positive laboratory result of the first infectious episode of 90 days is counted (even if a 2 nd episode occurs after 90 days).
    An invalidated case corresponds to a person having obtained a negative laboratory result. A person is considered a reversed case whenever a screening test result is negative, with the exception of negative tests obtained during a 90-day infectious episode. A person can be represented more than once.
    The number of eligible tests is the total number of screening tests performed, except those performed from day 2 to day 90 of an infectious episode of COVID-19. Only one test per person can be counted per collection date. This number is equal to the sum of confirmed and invalidated cases.
    The percent positivity (%) is the proportion of distinct episodes of COVID-19 among eligible tests in people susceptible to infection (i.e., excluding results issued within 90 days of first episode). The percentage of positivity is calculated by dividing the number of confirmed cases by the total number of admissible tests carried out (confirmed cases + rejected cases).

About the chart:

    The data presented in this graph is not cumulative. They are revised daily and retroactively.
    The percentage of positivity, unlike the cumulative number of people tested, includes cases canceled on samples taken on different dates (for people who had more than one sample for the same day, only one result is kept). For example, if a person tests negative on 1 st November positive on 3 November, 10 November and negative still negative 2 March 2021:
        On 1 st November, it will be included in the case overturned.
        On November 2, it will not be counted anywhere for that day.
        On November 3, she will be included in confirmed cases. His negative result of 1 st November will be retained in the calculation of positive rate of 1 st November.
        On November 10, his negative result will be excluded from the invalidated cases and from the calculation of the positivity rate (because the date of the negative test is included in the infectious episode of 90 days).
        On March 2, 2020, his negative result will be included in the invalidated cases and in the calculation of the positivity rate (since the 90 infectious days have passed).


| Total cases                      | reported total number of cases of infections to date, aggregated at regional, RLS or municipal level |
| Total deaths                     | reported total number of deaths at the regional level                                                |
| Total deaths (CHSLD)             | reported total number of deaths in residential and long-term care centres in the region              |
| Total Deaths (home & unknown)    | reported total number of deaths in homes and unknown locations in the region                         |
| Total deaths (other)             | reported total number of deaths in RIs and other facilities in the region                            |
| Total deaths (RPA)               | reported total number of deaths in private seniors' residences in the region                         |
| Total hospitalizations           | TBA                                                                                                  |

The “Cumulative hospitalizations” tile on the “  By region  ” page shows the cumulative number of new hospitalizations (incidental hospitalizations) since the start of the pandemic.

| Total Vaccine doses administered | cumulative vaccine doses administered in the region (may not be Outaouais residents)                 |
| Vaccine doses administered       | daily vaccine doses administered in the region (may not be Outaouais residents)                      |





The COVID-19 data in Quebec page presents data according to two types of date: the actual date of the event (date of declaration, death, sample analysis or hospital admission) and the date known as "Reported" for the tiles at the top of the page.
Actual dates of the event

All data using the "actual date of the event", whether it is the date of notification of the cases, the date of death, the date of analysis of the sample or the date of admission for hospitalizations, are data revised daily and retroactively.

Since there is a delay between the event and its recording in the information system, the evolution data presented by actual dates of events are always underestimated in the most recent days, in particular. especially for cases, deaths and hospitalizations. Due to the delay in entering information and events with a missing date in the system, the cumulative number of events according to the actual date is always lower than the cumulative number according to the reported date ("official report" announced by the government in the "Confirmed cases", "Death" and "Recovered" tiles of the COVID-19 data in Quebec main page).

All the adjustments to the data, such as for example the removal of duplicates, the modifications of living environments or the corrections of the age of a deceased person, are made retroactively on the data by actual dates of events. Thus, the adjustments made in the information system, such as catching up in the entry of death data, will have little impact on the epidemic curve since the affected cases generally spread over a certain period of time.

For all these reasons, data using the actual date of the event presents a better picture of reality than those using the reported date.
Declaration date

The date of declaration of a case corresponds to

    the date of receipt of the declaration by the Regional Directorate of Public Health or, if absent,
    the date of the epidemiological investigation or, if absent,
    the date of entry into the information system.

Date of death

Date entered in the death certificate, which corresponds to the moment when the death was certified by a doctor.
Date of admission

Date of admission to hospital.
Test result date

Date on which the test result is recorded in the laboratory information system.
Date of sample analysis

Date on which the sample was analyzed by a laboratory. The analysis can be done on the same day as the sample is taken or within a few days depending on the capacity of the laboratories.
Date reported

Data by reported date is the data newly entered into the system that is released on government balance sheets every day. These data are cumulative and do not take into account the actual date on which the event took place. For example, among the new deaths shown in brackets in the tiles, some may have occurred several days before. For details on the time of death, see:  https://www.quebec.ca/sante/problemes-de-sante/az/coronavirus-2019/situation-coronavirus-quebec(the link is external).

Data using the reported date is only shown in the Confirmed Cases, Deaths, and Recovered Persons tiles at the top of the COVID-19 Data in Quebec main page . Data by reported date is more affected by adjustments or corrections than data presented by actual event date. For example, a removal of duplicates in the system will affect the data by date reported on the day following the correction date.
