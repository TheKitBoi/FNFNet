import { Room, Client, matchMaker } from "colyseus";
import { Stuff } from "./schema/Stuff";
import * as readline from 'readline';
import { discord } from "../modules/discord";
import * as fs from 'fs';
var config = require("../../config.json"); //JSON.parse(fs.readFileSync("config.json", "utf-8"));
const dsc = new discord;
let rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});
/////////////////////////////////////////
//
//      FNFNet
//        Created by bit of trolling
//      Legend:
//      test - amount of users
//      theY - y position of chatText
//      
//
/////////////////////////////////////////
/*
      this.onMessage("string", async (client, message) => {

    }
        if (message.join){
            const room = await matchMaker.createRoom("battle", { mode: "duo" });
            
        }
    });
*/
interface PlayerData {
  name:string,
  ready:boolean,
  score:number,
  finished:boolean,
  loaded:boolean,
  registered:boolean,
  admin:boolean
}
export class BattleRoom extends Room<Stuff> {
  scorep1:number;
  scorep2:number;
  playedagame:boolean = false;
  startedGame:boolean = false;

  player1:PlayerData = {name: '', ready: false, score: 0, finished: false, loaded: false, registered: false, admin: false};
  player2:PlayerData = {name: '', ready: false, score: 0, finished: false, loaded: false, registered: false, admin: false};
  options = {vsMode: true};
  p1ready:Boolean;
  p2ready:Boolean;

  song: string;
  diff: number;
  week: number;
  maxClients = 2;
  public static stuff: string;
  onCreate (options: any) {
    this.setState(new Stuff());
    //this.autoDispose = true;
    this.song = "";
    this.diff = 0;
    this.week = 0
    this.scorep1 = 0;
    this.scorep2 = 0;
    this.roomId = this.genID();
    this.setPrivate(true);
    console.log(this.roomId);
    this.setMetadata({options: options})
    this.onMessage('misc', (client, message) => {
      try{
        if(client.sessionId == this.clients[0].sessionId) this.p1ready = message.ready;
        else this.p2ready = message.ready;
        if(this.p1ready && this.p2ready){
          this.startedGame = true;
          this.playedagame = true;
          this.broadcast('start');
        }
        this.broadcast('misc', {p1: this.p1ready, p2: this.p2ready});
      }catch(e){
        console.log(e);
      }
    });
    this.onMessage('songname', (client, message) => {
      var diffi;
      switch (message.diff)
      {
        case 0:
          diffi = "Easy";
          break;
        case 2:
          diffi = "Hard";
          break;
        default:
          diffi = 'Normal';
          break;
      };
      this.setMetadata({song: message.song, difficulty: diffi});
      this.song = message.song;
      this.diff = message.diff;
      this.week = message.week
      this.setPrivate(false);
      try{
        client.send("creatematch", {song: message.song, diff: message.diff, week: message.week});
      }catch(err){
        console.log(err);
      }
    });
    this.onMessage('recvprev', (client, message) => {
      if(client.sessionId == this.clients[0].sessionId) {
        this.player1.name = message.name;
        console.log(message.registered);
        this.setMetadata({song: message.song, hoster: message.name, registered: message.registered});
        this.player1.registered = message.registered;
      }
      else {
        this.player2.name = message.name;
        this.player2.registered = message.registered;
        this.broadcast('userjoin', {name: message.name, registered: message.registered});
      }
    });
    this.onMessage('chatHist', (client, message) => {
      if(this.clients[0].sessionId == client.sessionId){
        this.player1.name = message.name;
      }else {
        this.player2.name = message.name;
      }
      this.broadcast('chatHist', {p1name: this.player1.name, p2name: this.player2.name,  registered: this.player2.registered});
    });
    this.onMessage('loaded', (client, message) => {
      if(this.clients[0].sessionId == client.sessionId){
        this.player1.loaded = true;
      }else {
        this.player2.loaded = true;
      }
      if(this.player1.loaded && this.player2.loaded){
        this.broadcast("loaded");
      }
    });
    this.onMessage('finished', (client, message) => {
      if(this.clients[0].sessionId == client.sessionId){
        this.player1.finished = true;
      }else {
        this.player2.finished = true;
      }
      if(this.player1.finished && this.player2.finished){
        this.broadcast("finished");
      }
    });
    this.onMessage('bubble', (client, message) => {
      if(!this.startedGame && message.message != "")this.broadcast('bubble', {message: message.message, p1: client.sessionId==this.clients[0].sessionId?true:false});
    });
    this.onMessage('hitnote', (client, message) => {
      if(client.sessionId == this.clients[0].sessionId){
        this.broadcast('hitnote', {player: 1, strum: message.strum, held: message.held});
      }
      else if(client.sessionId == this.clients[1].sessionId){
        this.broadcast('hitnote', {player: 2, strum: message.strum, held: message.held});
      }
    });
    this.onMessage('optionchange', (client, message) => {
      options.vsMode = message.vsMode;
      this.broadcast('optionchange', {vsMode: message.vsMode});
    });
    this.onMessage("message", (client, message) => {
      if(this.startedGame){
        if(client.sessionId == this.clients[0].sessionId){
          switch(message.rating){
            case 'shit':
              this.scorep1 += 50;
            case 'bad':
              this.scorep1 += 100;
            case 'good':
              this.scorep1 += 200;
            case 'sick':
              this.scorep1 += 350;
          }
        }else{
          switch(message.rating){
            case 'shit':
              this.scorep2 += 50;
            case 'bad':
              this.scorep2 += 100;
            case 'good':
              this.scorep2 += 200;
            case 'sick':
              this.scorep2 += 350;
          }
        }
        try{
          this.broadcast("retscore", {p1score: this.scorep1, p2score: this.scorep2});
        }catch(error){
          console.log(error);
        }
      }
    });
  }
  onJoin (client: Client, options: any) {
    console.log('client joined');
    if(this.clients.length != 2) try{ client.send("message", {iden: this.roomId}); }catch(error){ console.log(error); }
    if(this.clients.length >= 2) {
      try{
        setTimeout(() => {
          if(this.clients.length >= 2) this.clients[1].send('message', {song: this.song, diff: this.diff, week: this.week, p1name: this.player1.name, p1registered: this.player1.registered, options: options});
        }, 2000);
      }catch(error){ console.log(error); }
    }
  }

  onLeave (client: Client, consented: boolean) {
    if(client.sessionId == this.clients[0].sessionId && !this.startedGame){
      this.disconnect();
    }else{
      if(!this.playedagame)this.player2.name = '';
      this.p2ready = false;
      this.broadcast('userleft', {})
      if(this.startedGame){this.setPrivate(true)}
      else{
        this.unlock();
      }
      if(this.playedagame){
        //this.autoDispose = true;
      }
      else this.setPrivate(false);
      this.player2.loaded = true;
    }
    if(this.clients.length == 0) console.log("the score is: " + this.scorep1);
    if(this.clients[0].sessionId == client.sessionId && this.startedGame){
      this.player1.finished = true;
    }else {
      this.player2.finished = true;
    }
  }

  onDispose() {
    if(this.playedagame){
      var whowon:string = "";
      if(this.scorep1 > this.scorep2) whowon = this.player1.name;
      if(this.scorep2 > this.scorep1) whowon = this.player2.name;
      dsc.battle(config.discord.battleurl, "", this.player1.name, this.player2.name, this.scorep1, this.scorep2, whowon, this.song);
    }
    console.log("room", this.roomId, "disposing...");
  }

  genID(){
    var chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJLKMNOPQRSTUVWXYZ123456789#';
    var bullarray:string = '';
    for(var i = 0; i < 5; i++){
      bullarray += chars[Math.floor(Math.random() * (chars.length - 1 + 1) + 0)];
    }
    return bullarray;
  }

}