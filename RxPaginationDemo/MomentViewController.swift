import UIKit
import RxCocoa
import RxSwift
import RxDataSources

fileprivate let MomentTableViewCellReusableIdentifier = "MomentTableViewCellReusableIdentifier"

let MomentTableViewCellWidth = (UIScreen.main.bounds.size.width - 45) / 2

final class MomentViewController: UIViewController {
    
    var disposeBag = DisposeBag()
    
    var refreshControl: UIRefreshControl = UIRefreshControl()
    
    let viewModel: MomentViewModel = MomentViewModel()
    
    var tableView: UITableView = {
       	let tv = UITableView()
        tv.register(MomentTableViewCell.self, forCellReuseIdentifier: MomentTableViewCellReusableIdentifier)
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let header = UIView()
        self.view.addSubview(header)
        header.snp.makeConstraints { make in
            make.top.left.right.equalTo(self.view)
            make.height.equalTo(73)
        }
        
        view.addSubview(tableView)
        tableView.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(1)
            make.bottom.left.right.equalTo(self.view)
        }
        
        self.tableView.alwaysBounceVertical = true
        self.tableView.addSubview(refreshControl)
        
        setupRx()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.isNavigationBarHidden = false
    }
    
    func setupRx() {
        
        self.viewModel.posts.asDriver()
            .drive(tableView.rx.items(cellIdentifier: MomentTableViewCellReusableIdentifier, cellType: MomentTableViewCell.self)) { index, model, cell in
                cell.configureWith(post: model)
            }
            .disposed(by: disposeBag)
        
        self.tableView.rx.setDelegate(self)
            .disposed(by: disposeBag)
        
        self.tableView.rx_reachedBottom
            .map { _ in () }
        	.bind(to: self.viewModel.loadNextPageTrigger)
        	.disposed(by: disposeBag)

        self.refreshControl.rx.controlEvent(.valueChanged)
            .bind(to: self.viewModel.refreshTrigger)
            .disposed(by: disposeBag)

        self.rx.sentMessage(#selector(UIViewController.viewWillAppear(_:)))
            .map { _ in () }
            .bind(to: viewModel.refreshTrigger)
            .disposed(by: disposeBag)
        
        self.viewModel.posts.asObservable()
            .map { _ in false }
        	.bind(to: self.refreshControl.rx.isRefreshing)
        	.disposed(by: disposeBag)
    }
}

extension MomentViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
