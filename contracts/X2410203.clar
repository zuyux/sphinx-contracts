;; Constants
(define-constant question-id u2410203)
(define-constant metadata u"QmbTShEq4s6mT816AAgPu9j36txn6VfXGJHv6fgVxpwNXx")

;; Store the contract owner (deployer of the contract)
(define-constant owner tx-sender)

;; Map to store the question status
(define-map question-status
  { question-id: uint }  ;; Key: question-id
  { status: (string-utf8 10) }  ;; Value: question status ("open", "closed")
)

;; Initialize the question as "open"
(define-public (initialize-question)
  (begin
    (map-set question-status { question-id: question-id }
      { status: u"open" })  ;; Set status to "open"
    (ok "Question initialized successfully")
  )
)

;; Read-only function to get the question metadata and status
(define-read-only (get-question-details)
  (match (map-get? question-status { question-id: question-id })
    question-data
    (ok 
      { 
        metadata: metadata,  ;; Return IPFS metadata link
        status: (get status question-data)  ;; Return current status
      }
    )
    (err u404)  ;; Return 404 if question not found
  )
)

;; Public function to close the question (only if called by the owner)
(define-public (close-question)
  (begin
    ;; Ensure only the owner can call this function
    (if (is-eq tx-sender owner)
      (match (map-get? question-status { question-id: question-id })
        question-data
        (let 
          (
            (current-status (get status question-data))  ;; Bind the status to a variable
          )
          ;; Check if the current status is "open"
          (if (is-eq current-status u"open")
            (begin
              ;; Update the status to "closed"
              (map-set question-status { question-id: question-id }
                { status: u"closed" })
              (ok "Question closed successfully")
            )
            (err u403)  ;; Error: Question already closed
          )
        )
        (err u404)  ;; Error: Question not found
      )
      (err u401)  ;; Error: Unauthorized (only owner can close the question)
    )
  )
)

;; Function to transfer funds (only the owner can transfer funds)
(define-public (transfer-funds (amount uint) (recipient principal))
  (begin
    ;; Ensure only the owner can call this function
    (if (is-eq tx-sender owner)
      (let ((balance (stx-get-balance (as-contract tx-sender))))  ;; Get contract balance
        (if (>= balance amount)
          (begin
            (let ((transfer-result (stx-transfer? amount (as-contract tx-sender) recipient)))
              (match transfer-result
                true (ok "Transfer successful")
                false (err u402)  ;; Error: Transfer failed
              )
            )
          )
          (err u402)  ;; Error: Insufficient funds
        )
      )
      (err u401)  ;; Error: Unauthorized (only owner can transfer funds)
    )
  )
)

(define-read-only (get-metadata)
  (ok metadata)) ;; Returns the constant metadata

(define-read-only (get-balance)
  (ok (stx-get-balance (as-contract tx-sender)))  ;; Get the contract's STX balance
)