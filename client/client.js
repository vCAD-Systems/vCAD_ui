import * as alt from 'alt';
import * as game from 'natives';

let tabletBrowser = null;
let lastInteract = 0;
let tabletReady = false;
let tablet = null;
let openSite = 'https://pc.' + site + 'net.li/tablet.php'

alt.on('keyup', (key) => {
    if (!canInteract) return;
	
	lastInteract = Date.now();
	
    if (key == 'N'.charCodeAt(0)) {
        if (tabletBrowser == null) {
            createCEF('cop', 'pc');
        } else {
            closeTabletCEF();
        }
    }
});

alt.on('WGC:Client:Tablet:open', (site, system) => {
	createCEF(site, system);
});

alt.on('WGC:Client:Tablet:close', () => {
	closeTabletCEF();
});

function createCEF(site, system) {
	if (!site) return;
    openTabletCEF(site, system);
    let coords = game.getEntityCoords(alt.Player.local.scriptID, true);
    let bone = game.getPedBoneIndex(alt.Player.local.scriptID, 28422);
    if (tablet) return;
    let tabletModel = game.getHashKey('prop_cs_tablet');
    game.requestAnimDict("cellphone@");
    alt.loadModel(tabletModel);
    let animInterval = alt.setInterval(() => {
        if (!game.hasAnimDictLoaded("cellphone@")) return;
        game.taskPlayAnim(alt.Player.local.scriptID, "cellphone@", "cellphone_cellphone_intro", 1.0, -1, -1, 50, 0, false, false, false);
        alt.clearInterval(animInterval);
    }, 0);
    let interval = alt.setInterval(() => {
        if (!game.hasModelLoaded(tabletModel)) return;
        tablet = game.createObject(tabletModel, coords.x, coords.y, coords.z, true, true, false);
        game.attachEntityToEntity(tablet, alt.Player.local.scriptID, bone, 0, 0, 0, 0, 0, 0, true, true, false, false, 2, true);
        alt.clearInterval(interval);
    }, 0);
}

function openTabletCEF(site, system) {
    if (tabletBrowser == null) {
        alt.showCursor(true);
        alt.toggleGameControls(false);
        tabletBrowser = new alt.WebView("http://resource/html/index.html");
        tabletBrowser.focus();
        tabletBrowser.on("WGC:Client:Tablet:isReady", () => {
			tabletReady = true;

			if (tabletBrowser != null) {
				let interval = alt.setInterval(() => {
					if (tabletReady) {
						alt.clearInterval(interval);
						if (system == 'pc') {
							openSite = 'https://pc.' + site + 'net.li/';
						} else {
							openSite = 'https://pc.' + site + 'net.li/tablet.php';
						}

						tabletBrowser.emit("WGC:CEF:Tablet:open", openSite);
					}
				}, 0);
			}
        });
    }
}

function closeTabletCEF() {
    if (tabletBrowser != null) {
        tabletBrowser.unfocus();
        tabletBrowser.destroy();
        tabletBrowser = null;
        alt.showCursor(false);
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