;Variáveis de controle
(defvar palavras nil)
(defvar listaAcertos nil)
(defvar tentativas nil)
(defvar palavraAtual nil)
(defvar countLine 1)
(defvar countAcertos 0)

;Função para embaralhar
(defun embaralhar (string)
    (let ((length (length string))
        (result (copy-seq string)))
      (dotimes (i length result)
          (dotimes (j length)
            (when (and (/= i j)
                     (char/= (aref string i) (aref result j))
                     (char/= (aref string j) (aref result i)))
              (rotatef (aref result i) (aref result j)))
          )
      )
     )
)
(defun onInit (nomeArquivo)
    (load "~/quicklisp/setup.lisp")
    (defvar arquivo nil)
    (setq arquivo (open (concatenate 'string "niveis/" nomeArquivo) :if-does-not-exist nil))
        (when arquivo
            (loop for line = (read-line arquivo nil)
                while line do
                (push line palavras)
            )
            (close arquivo)
        )
    (setq palavras (reverse palavras))
    (setq tentativas (parse-integer (nth 0 palavras)))
    (setq palavraAtual (nth countLine palavras))
    (pop palavras)
)
(defun contains (palavra)
    (loop for acertos in listaAcertos do
        (if (string= palavra acertos)
            (return-from contains t)
        )
    )
    (return-from contains nil)
)
(defun exibirPalavrasAcertadas ()
    (loop for palavra in palavras do
        (if (contains palavra) 
            (format t "~a" palavra)
            (loop for cont from 0 to (- (length palavra) 1 ) do
                (format t "*")
            )
        )
        (format t "~%")    
    )
)
(defun display (chance palavraAtual)
    (format t "~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%")
    (format t "~a~a~%" "Tentativas Restantes: " chance)
    (format t "~a ~%" "--Digite exit para sair--")
    (format t "~a~%" "Palavras:" )
    (exibirPalavrasAcertadas)
    (format t "~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%~%")
    (format t "~a ~a ~%" "Letras: " (embaralhar palavraAtual))
    (format t "~a" "Digite uma palavra: ")
)
(defun verificarAcerto (respostaUser)
    (loop for palavra in palavras do
        (if (string= palavra respostaUser)
            ((lambda ()
                (run-shell-command "play sons/acerto_sound.wav 2>lixo.txt")
                (return-from verificarAcerto t)
            ))
        )
    )
    (run-shell-command "play sons/erro_sound.wav 2>lixo.txt")
    (return-from verificarAcerto nil)
)
(defun main ()
    
    (format t "Selecione o nível desejado:~%(1)Fácil~%(2)Médio~%(3)Intermediário~%(4)Difícil~%(5)Supremo~%(6)Impossível~%")
    (defvar nivel (read))

    (case nivel
        (1 (setq arquivo "facil.txt"))
        (2 (setq arquivo "medio.txt"))
        (3 (setq arquivo "intermediario.txt"))
        (4 (setq arquivo "dificil.txt"))
        (5 (setq arquivo "supremo.txt"))
        (6 (setq arquivo "impossivel.txt"))
    )
    (onInit arquivo)
    (defvar respostaUser nil)
    (loop
        (display tentativas palavraAtual)
        (setq respostaUser (string-downcase (read)))
        (if (< tentativas 2)
            ((lambda ()
                (format t "Infelizmente você perdeu!")
                (run-shell-command "play sons/lose.wav 2>lixo.txt")
                (return-from main 0)
            ))
        )
        (if (> countAcertos (- (length palavras) 2 ))
            ((lambda ()
                (format t "~a" "Parabéns vc ganhou!")
                (run-shell-command "play sons/win.wav 2>lixo.txt")
                (return-from main 0)
            ))
        )
        (if (verificarAcerto respostaUser)
            ((lambda (respostaUser) 
                (push respostaUser listaAcertos)
                (incf countAcertos)
                (exibirPalavrasAcertadas))
            respostaUser)
            (decf tentativas) 
        )
        (when 
            (string= respostaUser "EXIT")
            (return-from main 0)
        )    
    )
)

(main)