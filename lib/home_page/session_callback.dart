
abstract class IApplicationSession {
  // Initialize app session for 5 minutes
  initApplicationSession();

  // every time this function gets called
  // stop app session
  // start/restart an idle countdown (e.g. 1min)
  // when to re-call initApplicationSession
  // for as long as this function is getting called
  // initApplicationSession is stopped
  // and the idle countdown is restarted
  // once the app stops calling this function
  // idle countdown will run out and it will re-initialize
  // initApplicationSession for 5 minutes
  // this cycle should loop until
  // initApplicationSession runs out.
  pauseAppSession();



  onExitProfilePage(bool didUpdate, String displayPic);
}