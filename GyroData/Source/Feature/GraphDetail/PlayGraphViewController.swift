//
//  PlayGraphViewController.swift
//  TestGyroData
//
//  Created by 엄철찬 on 2022/09/25.
//

import UIKit

class PlayGraphViewController: UIViewController {
    
    var motionInfo : MotionInfo?
    
    func setMotionInfo(_ motionInfo:MotionInfo){
        self.motionInfo = motionInfo
    }
    
    lazy var playView : Graph = {
        let view = Graph(id: .play, xPoints: [0.0], yPoints: [0.0], zPoints: [0.0])
        view.backgroundColor = .clear
        view.measuredTime = (motionInfo?.motionX.count) ?? 0
        return view
    }()
    
    var timer : Timer?
    var elapsedTime : Double = 0.0
    
    let timerLabel : UILabel = {
        let lbl = UILabel()
        lbl.font = .systemFont(ofSize: 30, weight: .heavy)
        lbl.text = "00.0"
        return lbl
    }()
    
    lazy var xLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .red
        return lbl
    }()
    lazy var yLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .green
        return lbl
    }()
    lazy var zLabel : UILabel = {
        let lbl = UILabel()
        lbl.textColor = .blue
        return lbl
    }()
    
    let plot : PlotView = {
       let view = PlotView()
        view.backgroundColor = .clear
        return view
    }()

    
    var isPlaying : Bool = false
    
    lazy var playBtn : UIButton = {
        let btn = UIButton()
        let img = UIImage(systemName: "play.fill")
        btn.setImage(img, for: .normal)
        btn.addTarget(self, action: #selector(touched), for: .touchUpInside)
        var config = UIButton.Configuration.plain()
        config.buttonSize = .large
        btn.configuration = config
        
        return btn
    }()
    
    @objc func touched(_ sender:UIButton){
        isPlaying.toggle()
        if isPlaying{
            
            let img = UIImage(systemName: "stop.fill")
            sender.setImage(img, for: .normal)

            playView.erase()
            playView.drawable = true
            
            
            //MARK: - 타이머 코드 추가
            timer = Timer(timeInterval: 0.1, repeats: true){ (timer) in
                                
                let elapsedTime = self.playView.elapsedTime
                               
                self.timerLabel.text = String(format:"%5.1f",Double(elapsedTime) / 10 + 0.1)
                
                if  elapsedTime >= (self.motionInfo?.motionX.count)! - 1{
                    timer.invalidate()
                    let img = UIImage(systemName: "play.fill")
                    sender.setImage(img, for: .normal)
                }
                
                let (x,y,z) = self.extractMotionInfo(self.motionInfo, at: elapsedTime)

                self.playView.getData(x: x, y: y, z: z)

                self.setLabelValue(x: x, y: y, z: z)
                
                self.playView.setNeedsDisplay()
                
       
            }
            if let timer = timer {
                RunLoop.current.add(timer, forMode: .default)
            }

        }else{
            //playView.pauseAnimation()
            let img = UIImage(systemName: "play.fill")
            sender.setImage(img, for: .normal)
            timer?.invalidate()
            elapsedTime = 0.0
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "다시보기"
        self.view.backgroundColor = .systemBackground

        addViews()
        
        setConstraints()
    }
    
    func addViews(){
        view.addSubview(plot)
        view.addSubview(playView)
        view.addSubview(playBtn)
        view.addSubview(timerLabel)
        view.addSubview(xLabel)
        view.addSubview(yLabel)
        view.addSubview(zLabel)
        
        plot.translatesAutoresizingMaskIntoConstraints = false
        playView.translatesAutoresizingMaskIntoConstraints = false
        playBtn.translatesAutoresizingMaskIntoConstraints = false
        timerLabel.translatesAutoresizingMaskIntoConstraints = false
        xLabel.translatesAutoresizingMaskIntoConstraints = false
        yLabel.translatesAutoresizingMaskIntoConstraints = false
        zLabel.translatesAutoresizingMaskIntoConstraints = false
    }
    
    func setConstraints(){
        NSLayoutConstraint.activate([
            plot.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            plot.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            plot.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            plot.heightAnchor.constraint(equalTo: plot.widthAnchor),
            playView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            playView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playView.widthAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.9),
            playView.heightAnchor.constraint(equalTo: playView.widthAnchor),
            playBtn.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            playBtn.topAnchor.constraint(equalTo: playView.bottomAnchor, constant: 30),
            //MARK: - 시간 표시 레이블 추가
            timerLabel.trailingAnchor.constraint(equalTo: playView.trailingAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: playBtn.centerYAnchor),
            timerLabel.widthAnchor.constraint(equalTo: playView.widthAnchor).constraintWithMultiplier(0.25),
            xLabel.centerXAnchor.constraint(equalTo: plot.centerXAnchor).constraintWithMultiplier(0.5),
            yLabel.centerXAnchor.constraint(equalTo: plot.centerXAnchor),
            zLabel.centerXAnchor.constraint(equalTo: plot.centerXAnchor).constraintWithMultiplier(1.5),
            xLabel.topAnchor.constraint(equalTo: plot.topAnchor),
            yLabel.topAnchor.constraint(equalTo: plot.topAnchor),
            zLabel.topAnchor.constraint(equalTo: plot.topAnchor)
        ])
    }
    
    func setLabelValue(x:Double, y:Double, z:Double){
        xLabel.text = "x:" + String(format:"%.2f",x)
        yLabel.text = "y:" + String(format:"%.2f",y)
        zLabel.text = "z:" + String(format:"%.2f",z)
    }
    
    func extractMotionInfo(_ motionInfo:MotionInfo?, at idx:Int) -> (Double,Double,Double){
        if let motionInfo = motionInfo{
            return (motionInfo.motionX[idx], motionInfo.motionY[idx], motionInfo.motionZ[idx])
        }
        return (0.0, 0.0, 0.0)
    }
