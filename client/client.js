import * as alt from 'alt';
import * as game from 'natives';
import {nearPos, currentPos} from './posmanager.js';

//"CONFIG"
const UseNewDesign = false;
//END OF "CONFIG"


let cursor = false,
    tabletBrowser = null,
    lastInteract = 0,
    tabletReady = false,
    tablet = null;

let openSite = 'https://copnet.ch/'

function canInteract() { return lastInteract + 1000 < Date.now() }

function OpenInVehicle(site, system) {
    const player = alt.Player.local;
    let vehicle = player.vehicle;

    if (tabletBrowser != null) {
        closeTabletCEF();
        return;
    }

    //Only open Tablet when in Vehicle with Emergency Class
    if (!vehicle || vehicle && game.getVehicleClass(vehicle.scriptID) != 18) {
        return;
    }

    openTabletCEF(site, system);
}

alt.on('keyup', (key) => {
    if (!canInteract) return;
    lastInteract = Date.now();
    
    //Keycodes: http://keycode.info/?ref=stuyk
    if (key == 69 && nearPos) { //E
        if (tabletBrowser == null) {
            openTabletCEF(currentPos.System, currentPos.OpenType, currentPos.PublicID || null);
        } else {
            closeTabletCEF();
        }
    } else if (key == 121) { //F10
        if (tabletBrowser == null) {
            openTabletCEF('cop', 'pc');

            //OpenInVehicle('cop', 'pc'); 
        } else {
            closeTabletCEF();
        }
    } else if (key == 120) { //F9
        if (tabletBrowser == null) {
            openTabletCEF('medic', 'pc');

            //OpenInVehicle('medic', 'pc'); 
        } else {
            closeTabletCEF();
        }
    } else if (key == 118) { //F7
        if (tabletBrowser == null) {
            openTabletCEF('car', 'pc');

            //OpenInVehicle('car', 'pc'); 
        } else {
            closeTabletCEF();
        }
    }
});

alt.on('vCAD:Client:Tablet:open', (site, system, publicID) => {
	openTabletCEF(site, system, publicID);
});

alt.on('vCAD:Client:Tablet:close', () => {
	closeTabletCEF();
});

function openTabletCEF(site, system, publicID) {
	if (!site || site != 'cop' && site != 'medic' && site != 'car' || publicID != null && site != 'car') {
        alt.log('[vCAD_UI] Site wurde nicht oder falsch angegeben!');
        return;
    }
    
    createCEF(site, system, publicID);
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
function getsite(system) {
    if (system == "cop") {
        return "https://copnet.ch/"
    } else if (system == "medic") {
		return "https://medicnet.ch/"
	} else if (system == "car") {
        return "https://mechnet.ch/"
    }
}
	
    

function createCEF(site, system, publicID) {
    if (tabletBrowser == null) {
        tabletBrowser = new alt.WebView("http://resource/html/index.html");

        tabletBrowser.on("vCAD:Client:Tablet:isReady", () => {
            tabletReady = true;
        });

        tabletBrowser.on("vCAD:Client:Tablet:close", closeTabletCEF);

        alt.setTimeout(() => {
            if (tabletBrowser == null) return;
            showCursor(true);
            alt.toggleGameControls(false);
            tabletBrowser.focus();

            let interval = alt.setInterval(() => {
                if (tabletReady) {
                    alt.clearInterval(interval);
                    openSite = getsite(site);

                    if (publicID != null) {
                        if (publicID == "HIER MUSS PUBLIC ID REIN!!") {
                            alt.log('[vCAD_UI] Ungültige PublicID!');
                            closeTabletCEF();
                            return;
                        }

                        openSite = 'https://mechnet.ch/shop.php?sp=' + publicID;
                    }

                    tabletBrowser.emit("vCAD:CEF:Tablet:open", openSite, UseNewDesign);
                }
            }, 0);
        }, 1500);
    }
}

function closeTabletCEF() {
    if (tabletBrowser != null) {
        tabletBrowser.off("vCAD:Client:Tablet:close", closeTabletCEF);
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