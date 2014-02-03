//
//  SearchViewController.m
//  pixster
//
//  Created by Timothy Lee on 7/30/13.
//  Copyright (c) 2013 codepath. All rights reserved.
//

#import "SearchViewController.h"
#import "UIImageView+AFNetworking.h"
#import "AFNetworking.h"
#import "PhotoCell.h"

@interface SearchViewController ()
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (nonatomic, strong) NSMutableArray *imageResults;
@property (nonatomic, strong) NSString *searchText;

- (void) doImageQuery:(NSString *)withString fromIndex:(int)index;

@end

@implementation SearchViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Pixster";
        self.imageResults = [NSMutableArray array];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // register the custom cell NIB
    UINib *customNib = [UINib nibWithNibName:@"PhotoCell" bundle:nil];
    [self.collectionView registerNib:customNib forCellWithReuseIdentifier:@"PhotoCell"];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableView data source

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    return [self.imageResults count];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    // Load more if user scrolled to bottom
    if (indexPath.row == self.imageResults.count - 1) {
        [self doImageQuery:self.searchText fromIndex:[self.imageResults count]];
    }
    
    PhotoCell *cell = [cv dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
    cell.imageView.image = nil;
    //cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    //cell.imageView.clipsToBounds = YES;
    [cell.imageView setImageWithURL:[NSURL URLWithString:[self.imageResults[indexPath.row] valueForKeyPath:@"url"]]];

    return cell;
}


#pragma mark - UISearchBar delegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    [searchBar setShowsCancelButton:NO animated:YES];
    
    self.searchText = [searchBar.text stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    [self.imageResults removeAllObjects];
    [self doImageQuery:self.searchText fromIndex:[self.imageResults count]];
    
    [self.view endEditing:YES];

}

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [searchBar setShowsCancelButton:YES animated:YES];
}

- (BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    return YES;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {

    //CGSize retval = photo.thumbnail.size.width > 0 ? photo.thumbnail.size : CGSizeMake(100, 100);
    CGFloat w = [[self.imageResults[indexPath.row] valueForKeyPath:@"tbWidth"] floatValue];
    CGFloat h = [[self.imageResults[indexPath.row] valueForKeyPath:@"tbHeight"] floatValue];
    CGSize retval = CGSizeMake(w, h);
    
    return retval;
}

- (UIEdgeInsets)collectionView:
(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section {
    return UIEdgeInsetsMake(10, 10, 10, 10);
}

- (void) doImageQuery:(NSString *)searchString fromIndex:(int)index {
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"http://ajax.googleapis.com/ajax/services/search/images?v=1.0&q=%@&start=%d", searchString, index]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        id results = [JSON valueForKeyPath:@"responseData.results"];
        if ([results isKindOfClass:[NSArray class]]) {
            [self.imageResults addObjectsFromArray:results];
            [self.collectionView reloadData];
        }
    } failure:nil];
    
    [operation start];

}
@end
