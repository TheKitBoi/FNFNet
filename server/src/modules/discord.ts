import fetch from 'cross-fetch';
/**
* home made discord api for fnfnet
*
* @param {string} send Send text to desired webhook
*/
export class discord {
    send(url:string, message:String){
        var data = { content: message.replace("@everyone", "also i love dicks btw").replace("@here", "also i love dicks btw"), allowed_mentions: false};

        //POST request with body equal on data in JSON format
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data),
        });
    }
    battle(url:string, message:String, p1name:string, p2name:string, p1score:number, p2score:number, whowon:string, song:string){
        var data = { content: message.replace("@everyone", "also i love dicks btw").replace("@here", "also i love dicks btw"), allowed_mentions: false, embeds: [{
            "title": whowon + " won the battle in " + song + "!",
            "fields": [
              {
                "name": p1name+"'s score:",
                "value": p1score,
                "inline": true
              },
              {
                "name": p2name+"'s score:",
                "value": p2score,
                "inline": true
              }
            ],
            "color": 1127128,
      }]
          };

        //POST request with body equal on data in JSON format
        fetch(url, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(data),
        });
    }
}
/*
embeds: [{
              "title": "guest2833 won the battle!",
              "fields": [
                {
                  "name": "guest2833's score:",
                  "value": "69420",
                  "inline": true
                },
                {
                  "name": "tiky fan 2009's score:",
                  "value": "130",
                  "inline": true
                }
              ],
              "color": 1127128,
        }]*/