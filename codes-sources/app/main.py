from fastapi import FastAPI, Request, Form, WebSocket, WebSocketDisconnect
from fastapi.responses import HTMLResponse
from fastapi.staticfiles import StaticFiles
from fastapi.templating import Jinja2Templates
import uvicorn
import asyncio
import json
from enum import Enum
import time
from typing import List, Dict

app = FastAPI(title="Système de Contrôle des Feux Tricolores")

# Configuration des fichiers statiques et des templates
app.mount("/static", StaticFiles(directory="static"), name="static")
templates = Jinja2Templates(directory="templates")

# Énumération des états des feux
class FeuEtat(str, Enum):
    ROUGE = "rouge"
    ORANGE = "orange"
    VERT = "vert"

# Classe pour représenter un feu tricolore
class FeuTricolore:
    def __init__(self, id: str, nom: str):
        self.id = id
        self.nom = nom
        self.etat = FeuEtat.ROUGE
        self.temps_restant = 0
    
    def to_dict(self):
        return {
            "id": self.id,
            "nom": self.nom,
            "etat": self.etat,
            "temps_restant": self.temps_restant
        }

# Classe pour gérer un carrefour de feux
class Carrefour:
    def __init__(self, id: str, nom: str):
        self.id = id
        self.nom = nom
        self.feux = []
        
    def ajouter_feu(self, feu: FeuTricolore):
        self.feux.append(feu)
        
    def to_dict(self):
        return {
            "id": self.id,
            "nom": self.nom,
            "feux": [feu.to_dict() for feu in self.feux]
        }

# Classe pour gérer le système complet
class SystemeFeuxTricolores:
    def __init__(self):
        self.carrefours = []
        self.en_marche = False
        self.mode_automatique = True
        self.duree_vert = 30  # secondes
        self.duree_orange = 5  # secondes
        self.duree_rouge = 35  # secondes
        self.connections: List[WebSocket] = []
        
    def ajouter_carrefour(self, carrefour: Carrefour):
        self.carrefours.append(carrefour)
        
    def to_dict(self):
        return {
            "carrefours": [carrefour.to_dict() for carrefour in self.carrefours],
            "en_marche": self.en_marche,
            "mode_automatique": self.mode_automatique,
            "duree_vert": self.duree_vert,
            "duree_orange": self.duree_orange,
            "duree_rouge": self.duree_rouge
        }
        
    async def connecter(self, websocket: WebSocket):
        await websocket.accept()
        self.connections.append(websocket)
        
    def deconnecter(self, websocket: WebSocket):
        self.connections.remove(websocket)
        
    async def envoyer_mise_a_jour(self):
        if not self.connections:
            return
        
        data = json.dumps(self.to_dict())
        for connection in self.connections:
            try:
                await connection.send_text(data)
            except WebSocketDisconnect:
                self.connections.remove(connection)
                
    async def cycle_automatique(self):
        while self.en_marche and self.mode_automatique:
            # Logique pour alterner les feux
            for carrefour in self.carrefours:
                for i, feu in enumerate(carrefour.feux):
                    # Décalage pour chaque feu
                    offset = i * (self.duree_vert + self.duree_orange + self.duree_rouge) // len(carrefour.feux)
                    asyncio.create_task(self.cycle_feu(feu, offset))
            
            await asyncio.sleep(1)  # Vérifier l'état toutes les secondes
            await self.envoyer_mise_a_jour()
    
    async def cycle_feu(self, feu: FeuTricolore, offset: int = 0):
        cycle_total = self.duree_vert + self.duree_orange + self.duree_rouge
        
        while self.en_marche and self.mode_automatique:
            # Calculer le temps dans le cycle en tenant compte du décalage
            temps_cycle = (int(time.time()) + offset) % cycle_total
            
            if temps_cycle < self.duree_vert:
                feu.etat = FeuEtat.VERT
                feu.temps_restant = self.duree_vert - temps_cycle
            elif temps_cycle < self.duree_vert + self.duree_orange:
                feu.etat = FeuEtat.ORANGE
                feu.temps_restant = self.duree_vert + self.duree_orange - temps_cycle
            else:
                feu.etat = FeuEtat.ROUGE
                feu.temps_restant = cycle_total - temps_cycle
            
            await asyncio.sleep(1)

# Initialisation du système
systeme = SystemeFeuxTricolores()

# Création des carrefours et des feux
carrefour1 = Carrefour("c1", "Carrefour Principal")
carrefour1.ajouter_feu(FeuTricolore("f1", "Nord-Sud"))
carrefour1.ajouter_feu(FeuTricolore("f2", "Est-Ouest"))
systeme.ajouter_carrefour(carrefour1)

carrefour2 = Carrefour("c2", "Carrefour Secondaire")
carrefour2.ajouter_feu(FeuTricolore("f3", "Nord-Sud"))
carrefour2.ajouter_feu(FeuTricolore("f4", "Est-Ouest"))
systeme.ajouter_carrefour(carrefour2)

# Routes FastAPI
@app.get("/", response_class=HTMLResponse)
async def accueil(request: Request):
    return templates.TemplateResponse("index.html", {"request": request})

@app.get("/api/systeme")
async def get_systeme():
    return systeme.to_dict()

@app.post("/api/demarrer")
async def demarrer_systeme():
    systeme.en_marche = True
    asyncio.create_task(systeme.cycle_automatique())
    return {"status": "success", "message": "Système démarré"}

@app.post("/api/arreter")
async def arreter_systeme():
    systeme.en_marche = False
    return {"status": "success", "message": "Système arrêté"}

@app.post("/api/mode")
async def changer_mode(mode: str = Form(...)):
    systeme.mode_automatique = (mode == "auto")
    if systeme.mode_automatique and systeme.en_marche:
        asyncio.create_task(systeme.cycle_automatique())
    return {"status": "success", "message": f"Mode changé en {mode}"}

@app.post("/api/feu/{feu_id}")
async def changer_etat_feu(feu_id: str, etat: str = Form(...)):
    if systeme.mode_automatique:
        return {"status": "error", "message": "Impossible de changer l'état en mode automatique"}
    
    for carrefour in systeme.carrefours:
        for feu in carrefour.feux:
            if feu.id == feu_id:
                feu.etat = etat
                await systeme.envoyer_mise_a_jour()
                return {"status": "success", "message": f"État du feu {feu_id} changé en {etat}"}
    
    return {"status": "error", "message": f"Feu {feu_id} non trouvé"}

@app.post("/api/duree")
async def changer_duree(vert: int = Form(...), orange: int = Form(...), rouge: int = Form(...)):
    systeme.duree_vert = vert
    systeme.duree_orange = orange
    systeme.duree_rouge = rouge
    return {"status": "success", "message": "Durées mises à jour"}

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await systeme.connecter(websocket)
    try:
        while True:
            await websocket.receive_text()
    except WebSocketDisconnect:
        systeme.deconnecter(websocket)

if __name__ == "__main__":
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
