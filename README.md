# Pretius Smart Checkbox Column
![](https://img.shields.io/badge/Plug--In%20Type-Dynamic%20Action-orange) ![](https://img.shields.io/badge/APEX-18.*-brightgreen) ![](https://img.shields.io/badge/APEX-19.*-brightgreen) ![](https://img.shields.io/badge/APEX-20.*-brightgreen) ![](https://img.shields.io/badge/APEX-21.*-brightgreen)

Oracle APEX Plugin that can be used for creating checkbox column in Classic and Interactive Report. The Plugin can be easly cofigured to provide different selection behavior and ways of storing selected values.

## Features at glance
* replace target column values with checkboxes
* store selected values in APEX Item or APEX collection
* single and multi selection modes
* higlight selected rows
* select rows with click outside of the checkbox
* customizable checkbox styles (with APEX Icons)

![Preview gif](images/preview.gif)

## License
MIT

## Free support
Pretius provides free support for the plugins at the GitHub platform. 
We monitor raised issues, prepare fixes, and answer your questions. However, please note that we deliver the plug-ins free of charge, and therefore we will not always be able to help you immediately. 

Interested in better support? 
* [Become a contributor!](#become-a-contributor) We always prioritize the issues raised by our contributors and fix them for free.
* [Consider comercial support.](#comercial-support) Options and benefits are described in the chapter below.

### Bug reporting and change requests
Have you found a bug or have an idea of additional features that the plugin could cover? Firstly, please check the Roadmap and Known issues sections. If your case is not on the lists, please open an issue on a GitHub page following these rules:
* issue should contain login credentials to the application at apex.oracle.com where the problem is reproduced;
* issue should include steps to reproduce the case in the demo application;
* issue should contain description about its nature.

### Implementation issues
If you encounter a problem during the plug-in implementation, please check out our demo application. We do our best to describe each possible use case precisely. If you can not find a solution or your problem is different, contact us: apex-plugins@pretius.com.

## Become a contributor!
We consider our plugins as genuine open source products, and we encourage you to become a contributor. Help us improve plugins by fixing bugs and developing extra features. Comment one of the opened issues or register a new one, to let others know what you are working on. When you finish, create a new pull request. We will review your code and add the changes to the repository.

By contributing to this repository, you help to build a strong APEX community. We will prioritize any issues raised by you in this and any other plugins.

## Comercial support
We are happy to share our experience for free, but we also realize that sometimes response time, quick implementation, SLA, and instant release for the latest version are crucial. That’s why if you need extended support for our plug-ins, please contact us at apex-plugins@pretius.com.
We offer:
* enterprise-level assistance;
* support in plug-ins implementation and utilization;
* dedicated contact channel to our developers;
* SLA at the level your organization require;
* priority update to next APEX releases and features listed in the roadmap.

## Roadmap
* [x] Support for mutliple instances of the plugin on the same report
* [x] Custom checkbox visualizations
* [x] Automatically adjust checkbox column width in Interactive Report
* [ ] No checkbox mode - row selection
* [ ] No header checkbox mode - plugin will not render header checkbox
* [ ] Google like - select all flag (all report pages)
* [x] Additional checkbox attributes (values) stored in APEX collection
* [ ] Custom selection callbacks
* [ ] Support for other APEX report types

## Known issues
* In case of database version lower than 19 selecting too many characters into collection produces an error. 

## Changelog

### 1.0.0 
Initial Release
### 1.1.0 
New features introduced:
* Support for mutliple instances of the plugin on the same report
* Custom checkbox visualizations
* Automatically adjust checkbox column width in Interactive Report
### 1.1.1 
Patch:
* Issue #1
* Broken select all checkbox after page refresh with all checkboxes selected
### 1.2.0 
New feature introduced:
* Multiple columns of the report can now be stored in APEX collection along with selected checkbox values

## About Author
Author | Github | Twitter | E-mail
-------|-------|---------|-------
Adam Kierzkowski | [@akierzkowski](https://github.com/akierzkowski) | [@a_kierzkowski](https://twitter.com/a_kierzkowski) | kierzkowski.a.m@gmail.com

## About Pretius
Pretius Sp. z o.o. Sp. K.

Pretius is a software company specialized in Java-based and low-code applications, with a dedicated team of over 25 Oracle APEX developers.
Members of our APEX team are technical experts, have excellent communication skills, and work directly with end-users / business owners of the software. Some of them are also well-known APEX community members, winners of APEX competitions, and speakers at international conferences.
We are the authors of the translate-apex.com project and some of the best APEX plug-ins available at the apex.world.
We are located in Poland, but working globally. If you need the APEX support, contact us right now.

Address | Website | E-mail
--------|---------|-------
Żwirki i Wigury 16A, 02-092 Warsaw, Poland | [http://www.pretius.com](http://www.pretius.com) | [office@pretius.com](mailto:office@pretius.com)



