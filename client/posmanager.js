import alt from 'alt-client';
import * as native from 'natives';
import { File } from 'alt';

export let nearPos = false;
export var currentPos = [];

let player = alt.Player.local;
var posArray = [];

if (File.exists('./positions.json')) {
    var posJSON = File.read('./positions.json');
    posArray = JSON.parse(posJSON);
    alt.setInterval(checkPos, 500);
} else {
    alt.log('[WGC_UI] Es existiert keine positions.json oder sie wurde verschoben!');
}

function checkPos() {
    for (var i in posArray) {
        let dist = native.getDistanceBetweenCoords(posArray[i].Coords.x, posArray[i].Coords.y, posArray[i].Coords.z, player.pos.x, player.pos.y, player.pos.z, true);
        
        if (dist <= posArray[i].Marker.x && !nearPos) {
            nearPos = true;
            currentPos = posArray[i];
            break;
        } else if (dist > posArray[i].Marker.x && nearPos) {
            nearPos = false;
            currentPos = [];
        }
    }
}

alt.everyTick(() => {
    if (posArray.length >= 1) {
        for (var i = 0; i < posArray.length; i++) {
            native.drawRect(0, 0, 0, 0, 0, 0, 0, 0);
            native.drawMarker(posArray[i].Marker.type, posArray[i].Coords.x, posArray[i].Coords.y, posArray[i].Coords.z, 0, 0, 0, 0, 0, 0, posArray[i].Marker.x, posArray[i].Marker.y, posArray[i].Marker.z, posArray[i].Marker.r, posArray[i].Marker.g, posArray[i].Marker.b, posArray[i].Marker.a, posArray[i].Marker.rotate, false, 2, false, undefined, undefined, false);
        }
    }

    if (nearPos) {
        helpNotify(currentPos.Prompt);
    }
});

function helpNotify(text) {
    native.beginTextCommandDisplayHelp('STRING');
    native.addTextComponentSubstringPlayerName(text);
    native.endTextCommandDisplayHelp(0, false, true, 0);
}