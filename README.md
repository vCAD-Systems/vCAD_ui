# vCAD_ui
Alt:V Standalone Ingame UI for vCAD/Copnet/Medicnet/Carnet.

# How to use:
```
alt.emit('vCAD:Client:Tablet:open', [TYPE], [SYSTEM], [PUBLICID]);
```

`[SYSTEM]` You can choose between Copnet (**cop**), Medicnet (**medic**) and Carnet (**car**).

`[TYPE]` You can choose between a Tablet (**tab**) and PC (**pc**) design.

`[PUBLICID]` Only needed for carnet.


You can close it with:
```
alt.emit('vCAD:Client:Tablet:close');
```

*If you make mistakes, the system will report to you automatically.*

# Made with love by Ffrankys, Flixxx, Mîhó & Tallerik <3
