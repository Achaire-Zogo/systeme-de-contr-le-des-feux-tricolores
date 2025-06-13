#!/bin/bash

# Script pour combiner les fichiers LaTeX en un seul document

# Préambule et début du document
cat > explication_files_attente_complet.tex << 'EOL'
\documentclass[11pt,a4paper]{article}
\usepackage[utf8]{inputenc}
\usepackage[T1]{fontenc}
\usepackage[french]{babel}
\usepackage{amsmath, amssymb}
\usepackage{geometry}
\usepackage{hyperref}
\usepackage{listings}
\usepackage{xcolor}
\usepackage{tikz}
\usepackage{pgf-umlsd}
\usepackage{pgfplots}
\usepackage{algorithm}
\usepackage{algpseudocode}
\usepackage{booktabs}
\usepackage{graphicx}
\usepackage{enumitem}
\geometry{margin=2.5cm}

% Définition du langage JavaScript pour listings
\lstdefinelanguage{JavaScript}{
  keywords={break, case, catch, continue, debugger, default, delete, do, else, finally, for, function, if, in, instanceof, new, return, switch, this, throw, try, typeof, var, void, while, with, let, const},
  keywordstyle=\color{blue}\bfseries,
  ndkeywords={class, export, boolean, throw, implements, import, this},
  ndkeywordstyle=\color{magenta}\bfseries,
  identifierstyle=\color{black},
  sensitive=true,
  comment=[l]{//},
  morecomment=[s]{/*}{*/},
  commentstyle=\color{gray}\ttfamily,
  stringstyle=\color{orange}\ttfamily,
  morestring=[b]',
  morestring=[b]"
}

% Style pour le code Event-B
\lstdefinestyle{EventB}{
  basicstyle=\ttfamily\footnotesize,
  backgroundcolor=\color{gray!10},
  frame=single,
  rulecolor=\color{black},
  breaklines=true,
  breakatwhitespace=true,
  showstringspaces=false
}

% Configuration de TikZ pour les diagrammes
\usetikzlibrary{arrows.meta, positioning, shapes.geometric, calc, fit, backgrounds, decorations.pathreplacing}
\tikzset{>=stealth'}

% Style du document
\hypersetup{
    colorlinks=true,
    linkcolor=blue,
    filecolor=magenta,      
    urlcolor=cyan,
    pdftitle={Système de Contrôle des Feux Tricolores},
    pdfauthor={Achaire Zogo}
}

% Titre et informations du document
\title{\LARGE\textbf{Optimisation des Feux Tricolores\\\vspace{0.5em}\normalsize{Modélisation Event-B et Minimisation du Temps d'Attente}}}
\author{Achaire Zogo}
\date{\today}
EOL

# Ajouter le contenu du modèle
cat explication_model.tex >> explication_files_attente_complet.tex

# Ajouter le contenu de la machine
cat explication_machine.tex >> explication_files_attente_complet.tex

# Ajouter le contenu de l'implémentation
cat explication_implementation.tex >> explication_files_attente_complet.tex

echo "Document LaTeX complet créé: explication_files_attente_complet.tex"
