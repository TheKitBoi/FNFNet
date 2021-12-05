const readline = require("readline");
import { exec } from "child_process";
import e from "express";
import * as fs from 'fs';
import { ChatRoom } from '../rooms/ChatRoom';
//why did i mix 2 variants of importing libraries
var ass: string;
const rl = readline.createInterface({
    input: process.stdin,
    output: ass
});
export class commandHandler {
    static start(){
        rl.question(">", function(cmd:string) {
            switch(cmd){
                case 'stop':
                    console.log("\nShutting down the server!");
                    process.exit(0);
                case 'save':
                    console.log("\nSaved the chat history!");
                    fs.writeFileSync('chatHistory.txt', ChatRoom.chatHistory);
                case 'vine boom':
                default:
                    if(cmd.startsWith("ban")){
                        const args = cmd.split(" ");
                        if(args[1] != null){
                            exec(`iptables -A INPUT -s ${args[1]} -j DROP`, (error, stdout, stderr) => {
                                if (error) {
                                    console.log(`error: ${error.message}`);
                                    return;
                                }
                                if (stderr) {
                                    console.log(`stderr: ${stderr}`);
                                    return;
                                }
                                console.log(`stdout: ${stdout}`);
                            });
                        }else console.log("\ninsert valid ip pls?");
                    }
            }
            commandHandler.start();
        });
    }
}

