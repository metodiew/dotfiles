<?php
/**
 * Theme's Functions file
 *
 * @file           functions.php
 * @author         Stanko Metodiev
 * @link           http://codex.wordpress.org/Theme_Development#Functions_File
 */

/**
 * Browser and OS detection
 * Detects user' OS and Browser and adds classes to the <body> tag
 */
function dx_browser_os_body_class( $classes ) {
    global $is_lynx, $is_gecko, $is_IE, $is_opera, $is_NS4, $is_safari, $is_chrome, $is_iphone;
    
    if ( $is_lynx ) { 
        $classes[] = 'lynx';
    } elseif ( $is_gecko ) {
        $classes[] = 'gecko';
    } elseif ( $is_opera ) {
        $classes[] = 'opera';
    } elseif ( $is_NS4 ) {
        $classes[] = 'ns4';
    } elseif( $is_safari ) {
        $classes[] = 'safari';
    } elseif( $is_chrome ) {
        $classes[] = 'chrome';
    } elseif( $is_IE ) {
	    $classes[] = 'ie';
	    if ( preg_match( '/MSIE ([0-9]+)([a-zA-Z0-9.]+)/', $_SERVER['HTTP_USER_AGENT'], $browser_version ) ) {
	    	$classes[] = 'ie' . $browser_version[1];
		}
    } else {
        $classes[] = 'unknown';
    }
    
    if( $is_iphone ) {
    	$classes[] = 'iphone';
	}
	
	if ( stristr( $_SERVER['HTTP_USER_AGENT'], 'mac' ) ) {
		$classes[] = 'osx';
	} elseif ( stristr( $_SERVER['HTTP_USER_AGENT'], 'linux' ) ) {
		$classes[] = 'linux';
	} elseif ( stristr( $_SERVER['HTTP_USER_AGENT'], 'windows' ) ) {
    	$classes[] = 'windows';
	}
    
	return $classes;
}

add_filter( 'body_class', 'dx_browser_os_body_class' );

/**
 * Return the src of the first image from post
 * @param string $post_id
 * @return void|string
 */
function catch_the_first_image( $post_id = null ) {
	if ( empty( $post_id ) ) {
		return;
	}
	
	$post = get_post( $post_id );
	$first_img = '';
	$output = preg_match_all( '/<img.+src=[\'"]([^\'"]+)[\'"].*>/i', $post->post_content, $matches );
	$first_img = isset( $matches[1][0] ) ? $matches[1][0] : '';

	return $first_img;
}

/**
 * Get Featured Image URL
 */
function dx_get_featured_image_url( $post_id ) {
	if ( empty( $post_id ) ) {
		return;
	}
	
	$image_args = wp_get_attachment_image_src( get_post_thumbnail_id( $post_id ), '' );
	
	$image = '';
	if ( ! empty( $image_args ) && is_array( $image_args ) ) {
		$image = $image_args[0];
	}
	
	return $image;
}
