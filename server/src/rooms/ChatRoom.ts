import { Room, Client } from "colyseus";
import { Stuff } from "./schema/Stuff";
import * as readline from 'readline';
import * as fs from 'fs';
import fetch from 'cross-fetch';
import { discord } from "../modules/discord";
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
var amUsers: number;
var theY: number = 0;
var users:Array<String> = new Array();
var uuids:Array<String> = new Array();
var hasAdmin:Array<Boolean> = new Array();
var chatHistory:String;
var thefullassmessage:String = "";
var test: number;
var config = JSON.parse(fs.readFileSync("config.json", "utf-8"));
const dsc = new discord();
export class ChatRoom extends Room<Stuff> {

  public static stuff: string;
  public static chatHistory: string = "";
  onCreate (options: any) {
    this.setState(new Stuff());
    this.autoDispose = false;
    this.onMessage("message", (client, message) => {
      console.log(message.message);
      var partofthefullassmessage:string = message.message;
      if(partofthefullassmessage.startsWith(">")){
        partofthefullassmessage = '[G]' + partofthefullassmessage + '[G]';
      }
      thefullassmessage = "<" + users[uuids.indexOf(client.sessionId)] + "> " + partofthefullassmessage; 
      chatHistory += thefullassmessage + "\n";
      theY -= 16;
      this.broadcast('message',{ message: thefullassmessage});
      ChatRoom.chatHistory = chatHistory as string;
      if(config.discord.enabled) dsc.send(config.discord.url, thefullassmessage);
    });
    
    this.onMessage("userdata", (client, message) => {      
      users[uuids.indexOf(client.sessionId)] = message.usname;
      this.broadcast('reul', {uslist: users});
    });
  }
  onJoin (client: Client, options: any) {
    console.log(client.sessionId, "joined!");
    test++;
    uuids.push(client.sessionId);
    hasAdmin.push(false);
    console.log(theY);
    var motd = fs.readFileSync("motd.txt", "utf-8");
    var rules = fs.readFileSync("rules.txt", "utf-8");
    console.log(motd);
    chatHistory += "Server: User has joined the chat!" + "\n";
    theY -= 16;
    client.send("recvprev", { chatHist: chatHistory, axY: theY as unknown as string, motd: motd, rules: rules}); // - 1  chathist: chatHistory, axY: theY, motd: motd, rules: rules, uslist: users
    this.broadcast("message", {message: "Server: User has joined the chat!"}, {except: client})
  }

  onLeave (client: Client, consented: boolean) {
    console.log(client.sessionId, "left!");
    users.splice(uuids.indexOf(client.sessionId), 1);
    hasAdmin.splice(uuids.indexOf(client.sessionId), 1);
    uuids.splice(uuids.indexOf(client.sessionId), 1);
    //uuids.remove(client.sessionId);
    test--;
    chatHistory += "Server: User has disconnected from the chat." + "\n";
    theY -= 16;
    this.broadcast('reul', {uslist: users, message: "Server: User has disconnected from the chat.\n"});
    client.leave();
  }

  onDispose() {
    console.log("room", this.roomId, "disposing...");
  }

}
