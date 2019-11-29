# XQRCode

## Description

XQRcode is a Xebia mobile app that allows the users to scan the client's QR code to check in them into the conference.

It's used by Xebia in some notable conferences such as [Xebicon](https://xebicon.fr/), [DataXDay](https://dataxday.fr/), [ParisContainerDay](https://paris-container-day.fr/) or [FrenchKit](https://frenchkit.fr/) to check in the people at their arrival.
There is also a [Back Office](https://admin.dev.xqrcode.fr/xebia/events).

## Purpose

Originally XQRCode was an app [written in React/Native](https://github.com/xebia-france/x-qrcode-mobile).
The purpose of this project is to rewrite the mobile app using Flutter because the current React/Native app has some issues that seem hard to solves.

The main focus subject will be: 
  * Improve the stability (big focus on the quality of the app)
  * Improve the scanning performance (QR code scan speed)

There is also a new feature that we want to implement during this project: `launch synchronization from a mobile`.
You can find the project's current advancement [here](https://trello.com/b/jdO1KNL2/x-qr-code).

There is some documentation that you could find here :
 * [API](https://github.com/xebia-france/x-qrcode-api/blob/multitenant/README.MD)
 * [Old project](https://github.com/xebia-france/x-qrcode-mobile/blob/master/README.md)
 * [Play Store application](https://play.google.com/store/apps/details?id=com.x_qrcode_mobile)

## CI/CD

We decided to use Bitrise as a CI/CD because it provides a nice integration with Flutter so it's effortless.
#### CI/CD Badge : [INSERT BADGE HERE]

## Development
### Versioning
We will use Git with Gitflow.

### Architecture
///////// NEED TO BE DISCUSSED ///////

### Code Review
For the code review, we should simply share the pull request once it's been rebased on `develop`. At least 1 review on each PR.
The template should be completed.

### Definition of Ready
There isn't any because of the speed required by the project.

### Definition of Done
Before passing a story to `Done` we should check that:
    * PR is merged.
    * Tests are written.
    * UI is coherent with the feature.
    * Feature compiled and checked.
    * CI/CD has passed once the PR was merged and is green.
    * ADR written if there is a need.

## Q&A

#### Why use Flutter?
There are 2 reasons :
  * Since Flutter announcement, some Xebians wanted to show that they can start a flutter project and be able to achieve them with good maintainability.
  * We wanted a fast development for this app and flutter provides us the possibility to create a cross-platform app faster.