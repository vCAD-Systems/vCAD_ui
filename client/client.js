import * as alt from 'alt';
import * as game from 'natives';
import {nearPos, currentPos} from './posmanager.js';

let cursor = false,
    tabletBrowser = null,
    lastInteract = 0,
    tabletReady = false,
    tablet = null;

let openSite = 'https://pc.copnet.li/'

function canInteract() { return lastInteract + 1000 < Date.now() }

alt.on('keyup', (key) => {
    if (!canInteract) return;
    lastInteract = Date.now();
    
    //Keycodes: http://keycode.info/?ref=stuyk
    if (key == 69 && nearPos) { //E
        if (tabletBrowser == null) {
            createCEF(currentPos.System, currentPos.OpenType, currentPos.PublicID || null);
        } else {
            closeTabletCEF();
        }
    } else if (key == 121) { //F10
        if (tabletBrowser == null) {
            createCEF('cop', 'pc');
        } else {
            closeTabletCEF();
        }
    } else if (key == 120) { //F9
        if (tabletBrowser == null) {
            createCEF('medic', 'pc');
        } else {
            closeTabletCEF();
        }
    } else if (key == 118) { //F7
        if (tabletBrowser == null) {
            createCEF('car', 'pc');
        } else {
            closeTabletCEF();
        }
    }
});

alt.on('WGC:Client:Tablet:open', (site, system, publicID) => {
	createCEF(site, system, publicID);
});

alt.on('WGC:Client:Tablet:close', () => {
	closeTabletCEF();
});

function createCEF(site, system, publicID) {
	if (!site || site != 'cop' && site != 'medic' && site != 'car' || publicID != null && site != 'car') {
        alt.log('[WGC_UI] Site wurde nicht oder falsch angegeben!');
        return;
    }
    
    openTabletCEF(site, system, publicID);
    let playerPos = alt.Player.local.pos;
    let bone = game.getPedBoneIndex(alt.Player.local.scriptID, 28422);
    if (tablet) return;
    let tabletModel = game.getHashKey('prop_cs_tablet');
    game.requestAnimDict("cellphone@");
    game.requestModel(tabletModel);
    
    let animInterval = alt.setInterval(() => {
        if (!game.hasAnimDictLoaded("cellphone@")) return;
        game.taskPlayAnim(alt.Player.local.scriptID, "cellphone@", "cellphone_cellphone_intro", 1.0, -1, -1, 50, 0, false, false, false);
        alt.clearInterval(animInterval);
    }, 0);

    let interval = alt.setInterval(() => {
        if (!game.hasModelLoaded(tabletModel)) return;
        tablet = game.createObject(tabletModel, playerPos.x, playerPos.y, playerPos.z, true, true, false);
        game.attachEntityToEntity(tablet, alt.Player.local.scriptID, bone, 0, 0, 0, 0, 0, 0, true, true, false, false, 2, true);
        alt.clearInterval(interval);
    }, 0);
}

function openTabletCEF(site, system, publicID) {
    if (tabletBrowser == null) {
        tabletBrowser = new alt.WebView("http://resource/html/index.html");

        tabletBrowser.on("WGC:Client:Tablet:isReady", () => {
            tabletReady = true;
        });

        tabletBrowser.on("WGC:Client:Tablet:close", closeTabletCEF);

        alt.setTimeout(() => {
            if (tabletBrowser == null) return;
            showCursor(true);
            alt.toggleGameControls(false);
            tabletBrowser.focus();

            let interval = alt.setInterval(() => {
                if (tabletReady) {
                    alt.clearInterval(interval);
                    openSite = 'https://pc.' + site + 'net.li/';

                    if (publicID != null) {
                        if (publicID == "HIER MUSS PUBLIC ID REIN!!") {
                            alt.log('[WGC_UI] Ungültige PublicID!');
                            closeTabletCEF();
                            return;
                        }

                        openSite = 'https://pc.carnet.li/shop.php?sp=' + publicID;
                    }

                    tabletBrowser.emit("WGC:CEF:Tablet:open", openSite);
                }
            }, 0);
        }, 1500);
    }
}

function closeTabletCEF() {
    if (tabletBrowser != null) {
        tabletBrowser.off("WGC:Client:Tablet:close", closeTabletCEF);
        tabletBrowser.unfocus();
        tabletBrowser.destroy();
        tabletBrowser = null;
        showCursor(false);
        alt.toggleGameControls(true);
    }

    tabletReady = false;
    game.clearPedTasks(alt.Player.local.scriptID);
    if (!tablet || tablet == null) return;
    alt.setTimeout(() => {
        game.detachEntity(tablet, true, false);
        game.deleteObject(tablet);
        tablet = null;
    }, 800);
}

function showCursor(state) {
    if(state === cursor) return;
    alt.showCursor(state);
    cursor = state;
} 