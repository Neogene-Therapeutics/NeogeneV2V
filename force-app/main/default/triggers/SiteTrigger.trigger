trigger SiteTrigger on Account (after insert) {
    new SiteTriggerHandler().run();
}