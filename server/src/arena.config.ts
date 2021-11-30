import Arena from "@colyseus/arena";
import { monitor } from "@colyseus/monitor";
import express, { query } from "express";
import { commandHandler } from "./modules/commandHandler";
import { BattleRoom } from "./rooms/BattleRoom";
import serveStatic from "serve-static";
import serveIndex from 'serve-index';
import { database } from './modules/database';
import sqlite, { Database } from 'sqlite3';
import bcrypt from 'bcrypt';
var accbase = new database;
/**
 * Import your Room files
 */
import { ChatRoom } from "./rooms/ChatRoom";
import { Stuff } from "./rooms/schema/Stuff";

export default Arena({
    
    getId: () => "FNFNet Server",

    initializeGameServer: (gameServer) => {
        /**
         * Define your room handlers:
         */
        gameServer.define('chat', ChatRoom);
        gameServer.define('battle', BattleRoom);

    },

    initializeExpress: (app) => {
        accbase.init();
        function symbolCheck(string:string){
            var format = /[!@#$%^&*()_+\-=\[\]{};':"\\|,.<>\/?]+/;
            return format.test(string);
        } //i suck at js 
        /**
         * Bind your custom express routes here:
         */
         app.use(express.urlencoded({ extended: true }));
         app.use(express.static('html'));

         app.use('/', (req, res, next) => {
            if (req.method !== 'GET' && req.method !== 'HEAD') {
                return next()
            }
            serveIndex("html", { icons: true })(req, res, next)
        });

        app.post("/edit/", (req, res, next) => {
            if(req.body.password == null || req.body.username == null || req.body.pfp == null || req.body.bg == null || symbolCheck(req.body.username)) return res.status(401).json({"message": "one or more of the four fields are null or your name contains symbols."});
            accbase.login(res, {username: req.body.username, password: req.body.password, action: "edit", pfp: req.body.pfp, bg: req.body.bg, phrase: req.body.phrase==null?"":req.body.phrase});
        });

        app.post("/login/", (req, res, next) => {
            if(req.body.password == null || req.body.username == null || req.body.action == null || req.body.value == null || symbolCheck(req.body.username)) return res.status(401).json({"message": "one or more of the four fields are null or your name contains symbols."});
            accbase.login(res, {username: req.body.username, password: req.body.password, action: req.body.action})
/*
            if(req.body.username == "janny"){
                if(req.body.password == "sneedsux"){
                    switch(req.body.action){
                        case "info":
                            accbase.accinfo(res, req.body.value);
                            break;
                        default:
                            res.status(404).send("no action specified");
                            break;
                    }
                }else{
                    res.status(401).send("invalid pass");
                }
            }
            else{
                res.status(401).send("invalid username");
            };
*/
        });
        app.post("/leaderboard/", (req, res) => {
            //;
            accbase.db.all("SELECT id, username, wins, loses, pfp, points FROM accounts ORDER BY points DESC LIMIT 10", (err, row) => {
                if(err || row == null) return res.status(401).json({"message": "Account not found", "data": err});
                res.status(200).json({
                    "message": "Account Info",
                    "data": row
                });
            });
        });

        app.post("/register/", (req, res, next) => {
            if(req.body.password == null || req.body.username == null || symbolCheck(req.body.username)) return res.status(401).json({"message": "one of two fields are null or your name contains symbols."});
            const hash = bcrypt.hashSync(req.body.password, 10);
            var uname = req.body.username;
            accbase.register(res, {username: uname, password: hash});
        });

        app.post("/info/", (req, res, next) => {
            if(req.body.id == null) return res.status(401).json({"message": "No ID specified."});
            accbase.accinfo(res, req.body.id);
        });

        /** 
         * Bind @colyseus/monitor
         * It is recommended to protect this route with a password.
         * Read more: https://docs.colyseus.io/tools/monitor/
         */
        app.use("/colyseus", monitor());
    },


    beforeListen: () => {
        commandHandler.start();
        /**
         * Before before gameServer.listen() is called.
         */
    },
});