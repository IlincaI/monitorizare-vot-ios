//  Created by Code4Romania

import Foundation
import UIKit

protocol QuestionViewControllerDelegate: class {
    func showNextQuestion(currentQuestion: MVQuestion)
}

class QuestionViewController: RootViewController, UITableViewDataSource, UITableViewDelegate, AnswerTableViewCellDelegate {
    
    // MARK: - iVars
    weak var delegate: QuestionViewControllerDelegate?
    var question: MVQuestion?
    var presidingOfficer: MVPresidingOfficer?
    private let answerWithTextTableViewCellConfigurator = AnswerWithTextTableViewCellConfigurator()
    private let basicAnswerTableViewCellConfigurator = BasicAnswerTableViewCellConfigurator()
    private var tapGestureRecognizer: UITapGestureRecognizer?
    private var answeredQuestionSaver = AnsweredQuestionSaver()
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var buttonHeight: NSLayoutConstraint!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        registerCell(identifier: "AnswerWithTextTableViewCell")
        registerCell(identifier: "BasicAnswerTableViewCell")
        registerCell(identifier: "QuestionBodyTableViewCell")
        setTapGestureRecognizer()
        tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(QuestionViewController.keyboardDidShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(QuestionViewController.keyboardDidHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Utils
    func keyboardDidShow(notification: Notification) {
        if let userInfo = notification.userInfo, let frame = userInfo[UIKeyboardFrameBeginUserInfoKey] as? CGRect {
            bottomConstraint.constant = frame.size.height - buttonHeight.constant
            performKeyboardAnimation()
        }
    }
    
    func keyboardDidHide(notification: Notification) {
        keyboardIsHidden()
    }
    
    func keyboardIsHidden() {
        bottomConstraint?.constant = 0
        performKeyboardAnimation()
        let cells = tableView.visibleCells
        for aCell in cells {
            if let aCell = aCell as? AnswerWithTextTableViewCell {
                aCell.textView.resignFirstResponder()
            }
        }
    }
    
    private func setTapGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(QuestionViewController.keyboardIsHidden))
        self.tapGestureRecognizer = tapGestureRecognizer
        self.view.addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func registerCell(identifier: String) {
        let nib = UINib(nibName: identifier, bundle: nil)
        tableView.register(nib, forCellReuseIdentifier: identifier)
    }
    
    // MARK: - UITableViewDataSource
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let question = self.question {
            return question.answers.count + 1
        }
        return 0
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionBodyTableViewCell") as! QuestionBodyTableViewCell
            cell.label.text = question!.text
            return cell
        }
        
        let answer = question!.answers[indexPath.row-1]
        
        if answer.inputAvailable {
            var cell = tableView.dequeueReusableCell(withIdentifier: "AnswerWithTextTableViewCell") as! AnswerWithTextTableViewCell
            cell = answerWithTextTableViewCellConfigurator.configure(cell: cell, answer: answer, delegate: self, selected: answer.selected) as! AnswerWithTextTableViewCell
            return cell
        } else {
            var cell = tableView.dequeueReusableCell(withIdentifier: "BasicAnswerTableViewCell") as! BasicAnswerTableViewCell
            cell = basicAnswerTableViewCellConfigurator.configure(cell: cell, answer: answer, delegate: self, selected: answer.selected) as! BasicAnswerTableViewCell
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return UITableViewAutomaticDimension
        }
        
        let answer = question!.answers[indexPath.row - 1]
        if answer.inputAvailable && answer.selected {
            return 234
        }
        return 64
    }

    // MARK: - IBActions
    @IBAction func buttonPressed(_ sender: UIButton) {
        let answeredQuestion = AnsweredQuestion(question: question!, presidingOfficer: presidingOfficer!)
        answeredQuestionSaver.save(answeredQuestion: answeredQuestion) {[weak self] (tokenExpired) in
            if tokenExpired {
                let _ = self?.navigationController?.popToRootViewController(animated: false)
            } else {
                self?.delegate?.showNextQuestion(currentQuestion: answeredQuestion.question)
            }
        }
    }
    
    // MARK: - AnswerTableViewCellDelegate
    func didTapOnButton(answer: MVAnswer) {
        let newAnswer = MVAnswer(id: answer.id, text: answer.text, selected: !answer.selected, inputAvailable: answer.inputAvailable, inputText: answer.inputText)
        
        var answers = [MVAnswer]()
        if let question = self.question {
            for aAnswer in question.answers {
                if aAnswer.id != newAnswer.id {
                    if question.type == .MultipleAnswer || question.type == .MultipleAnswerWithText {
                        answers.append(aAnswer)
                    } else {
                        let newAnswer = MVAnswer(id: aAnswer.id, text: aAnswer.text, selected: false, inputAvailable: aAnswer.inputAvailable, inputText: aAnswer.inputText)
                        answers.append(newAnswer)   
                    }
                } else {
                    answers.append(newAnswer)
                }
            }
            let questionUpdated = MVQuestion(form: question.form, id: question.id, text: question.text, type: question.type, answered: question.answered, answers: answers, synced: false)
            self.question = questionUpdated
            tableView.reloadData()
        }
    }
    
    func didChangeText(answer: MVAnswer, text: String) {
        let newAnswer = MVAnswer(id: answer.id, text: answer.text, selected: answer.selected, inputAvailable: answer.inputAvailable, inputText: text)
        
        var answers = [MVAnswer]()
        if let question = self.question {
            for aAnswer in question.answers {
                if aAnswer.id != newAnswer.id {
                    answers.append(aAnswer)
                } else {
                    answers.append(newAnswer)
                }
            }
            let questionUpdated = MVQuestion(form: question.form, id: question.id, text: question.text, type: question.type, answered: question.answered, answers: answers, synced: false)
            self.question = questionUpdated
        }
    }

    
}
