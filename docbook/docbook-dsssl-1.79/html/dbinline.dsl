;; $Id: dbinline.dsl,v 1.11 2004/09/14 14:47:10 petere78 Exp $
;;
;; This file is part of the Modular DocBook Stylesheet distribution.
;; See ../README or http://docbook.sourceforge.net/projects/dsssl/
;;

;; ============================== INLINES ===============================

(element abbrev (if %html40%
                    ($abbr-seq$)
                    ($charseq$)))
(element acronym (if %html40%
                     ($acronym-seq$)
                     ($charseq$)))
(element accel ($charseq$))
(element action ($charseq$))
(element application ($charseq$))
(element classname ($code-seq$))
(element constant ($code-seq$))
(element command ($bold-seq$))
(element computeroutput ($samp-seq$))
(element database ($charseq$))

(element email 
  ($code-seq$ 
   (make sequence 
     (literal "&#60;")
     (make element gi: "A"
	   attributes: (list (list "HREF" 
				   (string-append "mailto:" 
						  (data (current-node)))))
	   (process-children))
     (literal "&#62;"))))

(element errorcode ($charseq$))
(element errorname ($charseq$))
(element errortype ($charseq$))
(element envar ($code-seq$))
(element filename ($mono-seq$))         ; unsure
(element function ($code-seq$))
(element guibutton ($charseq$))
(element guiicon ($charseq$))
(element guilabel ($charseq$))
(element guimenu ($charseq$))
(element guimenuitem ($charseq$))
(element guisubmenu ($charseq$))
(element hardware ($charseq$))
(element interface ($charseq$))
(element interfacedefinition ($charseq$))
(element keycap ($bold-seq$))
(element keycode ($charseq$))

(element keycombo 
  (let* ((action (attribute-string (normalize "action")))
	 (joinchar 
	  (cond
	   ((equal? action (normalize "seq")) " ")          ;; space
	   ((equal? action (normalize "simul")) "+")        ;; +
	   ((equal? action (normalize "press")) "-")        ;; ? I don't know
	   ((equal? action (normalize "click")) "-")        ;; ? what to do
	   ((equal? action (normalize "double-click")) "-") ;; ? about the rest
	   ((equal? action (normalize "other")) "-")        ;; ? of these
	   (else "-"))))
    (let loop ((nl (children (current-node))) (count 1))
      (if (node-list-empty? nl)
	  (empty-sosofo)
	  (if (equal? count 1)
	      (make sequence
		(process-node-list (node-list-first nl))
		(loop (node-list-rest nl) (+ count 1)))
	      (make sequence
		(literal joinchar)
		(process-node-list (node-list-first nl))
		(loop (node-list-rest nl) (+ count 1))))))))

(element keysym ($charseq$))
(element literal ($mono-seq$))
(element medialabel ($italic-seq$))

(element menuchoice
  (let* ((shortcut (select-elements (children (current-node)) 
				    (normalize "shortcut")))
	 (items    (node-list-filter-by-not-gi
		    (children (current-node))
		    (list (normalize "shortcut")))))
    (make sequence
      (let loop ((nl items) (first? #t))
	(if (node-list-empty? nl)
	    (empty-sosofo)
	    (make sequence
	      (if first?
		  (process-node-list (node-list-first nl))
		  (make sequence
		    (if (or (equal? (gi (node-list-first nl))
				    (normalize "guimenuitem"))
			    (equal? (gi (node-list-first nl))
				    (normalize "guisubmenu")))
			(make sequence
			  (literal "-")
			  (make entity-ref name: "gt"))
			(literal "+"))
		    (process-node-list (node-list-first nl))))
	      (loop (node-list-rest nl) #f))))
      (if (node-list-empty? shortcut)
	  (empty-sosofo)
	  (make sequence
	    (literal " (")
	    (process-node-list shortcut)
	    (literal ")"))))))

(element methodname ($code-seq$))
(element shortcut ($bold-seq$))
(element mousebutton ($charseq$))
(element option ($code-seq$))

(element optional 
  (make sequence 
    (literal %arg-choice-opt-open-str%)
    ($charseq$)
    (literal %arg-choice-opt-close-str%)))

(element parameter ($code-seq$))
(element property ($charseq$))
(element prompt ($samp-seq$))
(element replaceable ($italic-mono-seq$))
(element returnvalue ($charseq$))
(element structfield ($code-seq$))
(element structname ($code-seq$))
(element symbol ($code-seq$))
(element systemitem ($charseq$))        ; ambiguous, should look at class
(element token ($charseq$))
(element type ($charseq$))              ; ambiguous
(element userinput ($kbd-seq$))
(element varname ($code-seq$))

(element citation 
  (if biblio-citation-check
      (let* ((bgraphies (select-elements (descendants (sgml-root-element))
					 (normalize "bibliography")))
	     (bchildren1 (expand-children bgraphies
					  (list (normalize "bibliography"))))
	     (bchildren2 (expand-children bchildren1
					  (list (normalize "bibliodiv"))))
	     (bibentries (node-list-filter-by-gi 
			  bchildren2
			  (list (normalize "biblioentry")
				(normalize "bibliomixed")))))
	(let loop ((bibs bibentries))
	  (if (node-list-empty? bibs)
	      (make sequence
		(error (string-append "Cannot find citation: " 
				      (data (current-node))))
		(literal "[") ($charseq$) (literal "]"))
	      (if (citation-matches-target? (current-node) 
					    (node-list-first bibs))
		  (make element gi: "A"
			attributes: (list 
				     (list "HREF" (href-to 
						   (node-list-first bibs))))
			(literal "[") ($charseq$) (literal "]"))
		  (loop (node-list-rest bibs))))))
      (make sequence 
	(literal "[") ($charseq$) (literal "]"))))

(element citerefentry
  (if %citerefentry-link%
      (make element gi: "A"
	    attributes: (list (list "HREF" ($generate-citerefentry-link$)))
	    (if %refentry-xref-italic%
		($italic-seq$)
		($charseq$)))
      (if %refentry-xref-italic%
	  ($italic-seq$)
	  ($charseq$))))

(define ($generate-citerefentry-link$)
  (empty-sosofo))

(define ($x-generate-citerefentry-link$)
  (let* ((refentrytitle (select-elements (children (current-node))
					 (normalize "refentrytitle")))
	 (manvolnum (select-elements (children (current-node))
				     (normalize "manvolnum"))))
    (string-append "http://example.com/cgi-bin/man.cgi?"
		   (data refentrytitle)
		   "("
		   (data manvolnum)
		   ")")))

(element citetitle
  (if (equal? (attribute-string (normalize "pubwork")) "article")
      (make sequence
	(literal (gentext-start-quote))
	(process-children)
	(literal (gentext-end-quote)))
      ($italic-seq$)))

(element emphasis
  (let* ((class (if (and (attribute-string (normalize "role"))
			 %emphasis-propagates-style%)
		    (attribute-string (normalize "role"))
		    "emphasis")))
    (make element gi: "SPAN"
	  attributes: (list (list "CLASS" class))
	  (if (and (attribute-string (normalize "role"))
		   (or (equal? (attribute-string (normalize "role")) "strong")
		       (equal? (attribute-string (normalize "role")) "bold")))
	      ($bold-seq$)
	      ($italic-seq$)))))

(element foreignphrase ($italic-seq$))
(element markup ($charseq$))

(element phrase
  (let* ((class (if (and (attribute-string (normalize "role"))
			 %phrase-propagates-style%)
		    (attribute-string (normalize "role"))
		    "phrase")))
    (make element gi: "SPAN"
	  attributes: (list (list "CLASS" class))
	  ($charseq$))))

(element quote
  (let* ((hnr   (hierarchical-number-recursive (normalize "quote") 
					       (current-node)))
	 (depth (length hnr)))
    (make element gi: "SPAN"
	  attributes: '(("CLASS" "QUOTE"))
	  (if (equal? (modulo depth 2) 1)
	      (make sequence
		(literal (gentext-start-nested-quote))
		(process-children)
		(literal (gentext-end-nested-quote)))
	      (make sequence
		(literal (gentext-start-quote))
		(process-children)
		(literal (gentext-end-quote)))))))

(element sgmltag
  (let ((class (if (attribute-string (normalize "class"))
		   (attribute-string (normalize "class"))
		   (normalize "element"))))
<![CDATA[
  (cond
   ((or (equal? class (normalize "attribute"))
        (equal? class (normalize "attvalue"))
        (equal? class (normalize "element"))) ($code-seq$))
   ((equal? class (normalize "endtag")) ($code-seq$ (make sequence 
						      (literal "</") 
						      (process-children)
						      (literal ">"))))
   ((equal? class (normalize "genentity")) ($code-seq$ (make sequence
							 (literal "&")
							 (process-children)
							 (literal ";"))))
   ((equal? class (normalize "numcharref")) ($code-seq$ (make sequence
							  (literal "&#")
							  (process-children)
							  (literal ";"))))
   ((equal? class (normalize "paramentity")) ($code-seq$ (make sequence
							   (literal "%")
							   (process-children)
							   (literal ";"))))
   ((equal? class (normalize "pi")) ($code-seq$ (make sequence 
						  (literal "<?")
						  (process-children)
						  (literal ">"))))
   ((equal? class (normalize "xmlpi")) ($code-seq$ (make sequence 
						  (literal "<?")
						  (process-children)
						  (literal "?>"))))
   ((equal? class (normalize "starttag")) ($code-seq$ (make sequence 
							(literal "<") 
							(process-children)
							(literal ">"))))
   ((equal? class (normalize "emptytag")) ($code-seq$ (make sequence 
							(literal "<") 
							(process-children)
							(literal "/>"))))
   ((equal? class (normalize "sgmlcomment")) ($code-seq$ (make sequence 
							   (literal "<!--")
							   (process-children)
							   (literal "-->"))))
]]>
  (else ($charseq$)))))

(element trademark
  (make sequence
    ($charseq$)
    (cond
     ((equal? (attribute-string "class") (normalize "copyright"))
      (make entity-ref name: "copy"))
     ((equal? (attribute-string "class") (normalize "registered"))
      (make entity-ref name: "reg"))
     ((equal? (attribute-string "class") (normalize "service"))
      (make element gi: "SUP"
	    (literal "SM")))
     (else
      (make entity-ref name: "#8482")))))

(element wordasword ($italic-seq$))

(element lineannotation
  (process-children))

(element superscript 
  (make element gi: "SUP"
	(process-children)))

(element subscript
  (make element gi: "SUB"
	(process-children)))
