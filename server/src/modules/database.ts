import sqlite from 'sqlite3';
import bcrypt from 'bcrypt';
export class database
{
    db:sqlite.Database;

    init(){
        this.db = new sqlite.Database('database.db', (err) => {
            if (err) {
              throw console.error(err.message);
            } //id, username, password, points, creation, banned, admin, friends
            this.db.exec("CREATE TABLE `accounts` (`id` INTEGER PRIMARY KEY AUTOINCREMENT,`username` VARCHAR(24),`password` VARCHAR(128), `phrase` VARCHAR(64) DEFAULT 'Phrase has not been set',`pfp` VARCHAR(2048) DEFAULT '', `bg` VARCHAR(2048) DEFAULT '', `wins` INTEGER unsigned DEFAULT 0, `loses` INTEGER unsigned DEFAULT 0, `points` INTEGER unsigned DEFAULT 0,`creation` DATETIME DEFAULT CURRENT_TIMESTAMP, `banned` BOOLEAN DEFAULT false, `admin` BOOLEAN DEFAULT false, `friends` TEXT);", 
             (row) => {
            //     const hash = bcrypt.hashSync('chuck', 10);
            //     this.db.exec(`INSERT INTO accounts (id, username, password, phrase, points, pfp) VALUES (NULL, 'chuck', '${hash}', 'default', 9, '');`);
                
            //     this.db.exec(`INSERT INTO accounts (id, username, password, phrase, points, pfp, bg) VALUES (NULL, 'sneed', '${hash}', 'look at the city slicker pullin up on his fancy german car!', 12567, 'https://static.wikia.nocookie.net/simpsons/images/8/8c/Chuck_farmer.png', 'https://i.kym-cdn.com/photos/images/original/002/227/731/245');`);
            });
            console.log('Connected to the in-memory SQlite database.');
          });
    }

    accinfo(res:any, id:number){
        this.db.get("SELECT * FROM accounts WHERE id=?", [id], (err, row) => {
            if(err || row == null) return res.status(401).json({"message": "Account not found", "data": err});
            res.status(200).json({
                "message": "Account Info",
                "id": row.id,
                "username": row.username,
                "wins": row.wins,
                "loses": row.loses,
                "pfp": row.pfp,
                "bg": row.bg,
                "phrase": row.phrase,
                "points": row.points,
                "creation": row.creation,
                "banned": row.banned,
                "admin": row.admin
            });
        });
    }

    test(res:any){
        return "aSS";
    };

    login(res:any, shit:any){
        this.db.get("SELECT * FROM accounts WHERE username=?", [shit.username], (err, row) => {
            if(err || row == null) return res.status(401).json({"message": "Account not found", "data": err});
            var pw = bcrypt.compareSync(shit.password, row.password);
            if(pw){
                switch(shit.action){
                    case "win":
                        this.db.run("UPDATE accounts SET points = points + 5, wins = wins + 0.5 WHERE username=?", [shit.username], (err) => {
                            if(err) res.status(500).json({"message": "Could not increase points.", "data": err});
                            else res.status(200).json({"message": "Points Increased.", "data": err, "oldscore": row.points, "score": row.points + 5});
                        });
                        break;
                    case "lose":
                        this.db.run("UPDATE accounts SET points = points + 1, loses = loses + 0.5 WHERE username=?", [shit.username], (err) => {
                            if(err) res.status(500).json({"message": "Could not increase points.", "data": err});
                            else res.status(200).json({"message": "Points Increased.", "data": err, "oldscore": row.points, "score": row.points + 1});
                        });
                        break;
                    case "accinfo":
                        res.status(200).json({
                            "message": "Account Info",
                            "id": row.id,
                            "username": row.username,
                            "wins": row.wins,
                            "loses": row.loses,
                            "pfp": row.pfp,
                            "bg": row.bg,
                            "phrase": row.phrase,
                            "points": row.points,
                            "creation": row.creation,
                            "banned": row.banned,
                            "admin": row.admin
                        });
                        break;
                    case "edit":
                        this.db.run("UPDATE accounts SET pfp = ?, bg = ?, phrase = ? WHERE username=?", [shit.pfp, shit.bg, shit.phrase, shit.username], (err) => {
                            if(err) res.status(500).json({"message": "Could not.", "data": err});
                            res.status(200).json({
                                "message": "Account changed",
                                "data": ""
                            });

                        });
                        break;
                    default:
                        res.status(200).json({"message": "Logged in but no action specified", "data": err});
                        break;
                }
            }
            else{
               res.status(401).json({"message": "Invalid Password", "data": err}); 
            }
        });
    };
    register(res:any, shit:any){
        this.db.get("SELECT * FROM accounts WHERE username=?", [shit.username], (err, row)=>{
            if(row != undefined) return res.status(401).json({"message": "Account already exists.", "data": err});
            this.db.run("INSERT INTO accounts (id, username, password) VALUES (NULL, ?, ?);", [shit.username, shit.password], () => {
               res.status(200).json({"message": "account created"});
            });
        });
    }
}
/*
⠀⠀⠀⠀⠀⠀⠀⢀⡠⠔⠒⠒⠒⠒⠒⠢⠤⣀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⡰⠉⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠑⢄⡀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⡸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⡀⠀⠀⠀⠀⠙⠄⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠃⠀⢠⠂⠀⠀⠘⡄⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢸⠀⠀⠀⠀⠀⠀⠀⠀⠈⢤⡀⢂⠀⢨⠀⢀⡠⠈⢣⠀⠀⠀⠀⠀
⠀⠀⠀⠀⢀⢀⡖⠒⠶⠤⠭⢽⣟⣗⠲⠖⠺⣖⣴⣆⡤⠤⠤⠼⡄⠀⠀⠀⠀
⠀⠀⠀⠀⠘⡈⠃⠀⠀⠀⠘⣺⡟⢻⠻⡆⠀⡏⠀⡸⣿⢿⢞⠄⡇⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢣⡀⠤⡀⡀⡔⠉⣏⡿⠛⠓⠊⠁⠀⢎⠛⡗⡗⢳⡏⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢱⠀⠨⡇⠃⠀⢻⠁⡔⢡⠒⢀⠀⠀⡅⢹⣿⢨⠇⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢸⠀⠠⢼⠀⠀⡎⡜⠒⢀⠭⡖⡤⢭⣱⢸⢙⠆⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⡸⠀⠀⠸⢁⡀⠿⠈⠂⣿⣿⣿⣿⣿⡏⡍⡏⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⢀⠇⠀⠀⠀⠀⠸⢢⣫⢀⠘⣿⣿⡿⠏⣼⡏⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⣀⣠⠊⠀⣀⠎⠁⠀⠀⠀⠙⠳⢴⡦⡴⢶⣞⣁⣀⣀⡀⠀⠀⠀⠀⠀
⠐⠒⠉⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⠀⢀⠤⠀⠀⠀⠀⠀⠀⠀⠈⠉⠀⠀⠀⠀

>YOU WILL EAT THE BUGS
>YOU WILL LIVE IN A POD
>YOU WILL HAVE SEX
>YOU WILL OWN NOTHING AND YOU WILL BE HAPPY
*/