//
// FSVLOBTableController.m
// LockWatch
//
// Created by janikschmidt on 7/13/2020
// Copyright © 2020 Team FESTIVAL. All rights reserved
//

#import "FSVLOBTableController.h"

extern NSString* LWOLocalizedString(NSString* key, NSString* value);

@implementation FSVLOBTableController

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
	[self.tableView setDelegate:self];
	[self.tableView setDataSource:self];
	[self.tableView setBackgroundColor:UIColor.clearColor];
	[self.tableView setBackgroundView:nil];
	[self.tableView setTranslatesAutoresizingMaskIntoConstraints:NO];
	[self.tableView setScrollEnabled:NO];
	[self.tableView registerClass:UITableViewCell.class forCellReuseIdentifier:@"Cell"];
	
	_tableViewHeightConstraint = [self.tableView.heightAnchor constraintEqualToConstant:self.tableView.contentSize.height];
	[NSLayoutConstraint activateConstraints:@[_tableViewHeightConstraint]];
	
	[self.tableView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
	[super viewWillAppear:animated];
	
	[self reloadTableView];
	[self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:self.isMovingFromParentViewController];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
	[self reloadTableView];
}

#pragma mark - Instance Methods

- (void)reloadTableView {
	[self.tableView reloadData];
	[self.tableView layoutIfNeeded];
	
	[_tableViewHeightConstraint setConstant:self.tableView.contentSize.height];
}

#pragma mark - FSVLOBBaseSetupControllerInterface

- (void)buttonTapped:(OBTrayButton*)button {}

- (NSString*)nextFlowItem {
	return nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	if (!_flowItemDefinition[@"TableViewSections"]) return 0;
	
    return [_flowItemDefinition[@"TableViewSections"] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	if (!_flowItemDefinition[@"TableViewSections"]) return 0;
	
    return [_flowItemDefinition[@"TableViewSections"][section][@"Items"] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
	
	if (!cell) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
	}
	
	[cell setBackgroundColor:UIColor.clearColor];
	[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
	[cell.textLabel setFont:[UIFont systemFontOfSize:17.0 weight:UIFontWeightSemibold]];

	[cell.textLabel setText:LWOLocalizedString(_flowItemDefinition[@"TableViewSections"][indexPath.section][@"Items"][indexPath.row][@"Title"], nil)];
	[cell.detailTextLabel setText:LWOLocalizedString(_flowItemDefinition[@"TableViewSections"][indexPath.section][@"Items"][indexPath.row][@"DetailText"], nil)];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
	return LWOLocalizedString(_flowItemDefinition[@"TableViewSections"][section][@"FooterText"], nil);
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
	return LWOLocalizedString(_flowItemDefinition[@"TableViewSections"][section][@"Label"], nil);
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	if (_flowItemDefinition[@"TableViewSections"][indexPath.section][@"Items"][indexPath.row][@"NextFlowItem"]) {
		[self.flowItemDelegate moveToFlowItem:_flowItemDefinition[@"TableViewSections"][indexPath.section][@"Items"][indexPath.row][@"NextFlowItem"] animated:YES];
	}
}

@end