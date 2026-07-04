import fs from 'fs';
import path from 'path';

export interface Photo {
    file: string;
    caption: string;
    featured?: boolean;
    /**
     * Controls public visibility. Defaults to true when omitted.
     * Set to false to hide a photo from the public site while keeping it
     * available in the private review tool (keep/discard curation).
     */
    published?: boolean;
}

/** A photo is shown publicly unless explicitly unpublished. */
export function isPublished(photo: Photo): boolean {
    return photo.published !== false;
}

export interface Album {
    title: string;
    slug: string;
    date: string;
    location: string;
    categories: string[];
    description: string;
    cover: string;
    photos: Photo[];
    imagePath: string; // The base directory path for images
}

export interface Category {
    name: string;
    slug: string;
    cover: string; // path relative to content like albums/slug/photo.jpg
}

export interface FeaturedImage {
    albumSlug: string;
    file: string;
    title: string;
    category: string;
}

const basePath = process.cwd();

export async function getSiteConfig() {
    const configPath = path.join(basePath, 'content', 'site-config.json');
    return JSON.parse(fs.readFileSync(configPath, 'utf-8'));
}

// Editable text/config for the static pages (Home, Portfolio, About, Contact).
// Falls back to sensible defaults if the file is missing or malformed so the
// build never breaks.
const PAGE_DEFAULTS = {
    home: {
        heroImage: { albumSlug: 'couples', file: '_DSC3081.jpg' },
        ctaText: 'Explore Portfolio',
        featuredHeading: 'Featured Collections',
    },
    portfolio: {
        heading: 'Portfolio',
        subtitle: 'A curated collection of portraits, events, and the quiet moments in between.',
    },
    about: {
        heading: 'About Me',
        subheading: 'The Eye Behind the Lens',
        paragraphs: [] as string[],
        profileImage: { albumSlug: '', file: '' },
        gear: [] as { label: string; value: string }[],
        people: [] as any[],
    },
    contact: {
        heading: "Let's Connect",
        intro: '',
    },
};

export async function getPages(): Promise<any> {
    const p = path.join(basePath, 'content', 'pages.json');
    if (!fs.existsSync(p)) return PAGE_DEFAULTS;
    try {
        const raw = JSON.parse(fs.readFileSync(p, 'utf-8'));
        return {
            home: { ...PAGE_DEFAULTS.home, ...(raw.home || {}) },
            portfolio: { ...PAGE_DEFAULTS.portfolio, ...(raw.portfolio || {}) },
            about: { ...PAGE_DEFAULTS.about, ...(raw.about || {}) },
            contact: { ...PAGE_DEFAULTS.contact, ...(raw.contact || {}) },
        };
    } catch {
        return PAGE_DEFAULTS;
    }
}

export async function getCategories(): Promise<Category[]> {
    const categoriesPath = path.join(basePath, 'content', 'categories.json');
    const raw = JSON.parse(fs.readFileSync(categoriesPath, 'utf-8'));
    return Array.isArray(raw) ? raw : raw.categories;
}

export async function getFeaturedImages(): Promise<FeaturedImage[]> {
    const featuredPath = path.join(basePath, 'content', 'featured.json');
    if (!fs.existsSync(featuredPath)) return [];
    const raw = JSON.parse(fs.readFileSync(featuredPath, 'utf-8'));
    return Array.isArray(raw) ? raw : raw.featured;
}

export async function getAlbums(): Promise<Album[]> {
    const albumsPath = path.join(basePath, 'content', 'albums');
    if (!fs.existsSync(albumsPath)) return [];

    const directories = fs.readdirSync(albumsPath, { withFileTypes: true })
        .filter(dirent => dirent.isDirectory())
        .map(dirent => dirent.name);

    const albums: Album[] = [];

    for (const dir of directories) {
        const metaPath = path.join(albumsPath, dir, '_album.json');
        if (fs.existsSync(metaPath)) {
            const metadata = JSON.parse(fs.readFileSync(metaPath, 'utf-8'));
            albums.push({ ...metadata, imagePath: `content/albums/${dir}` });
        }
    }

    return albums.sort((a, b) => new Date(b.date).getTime() - new Date(a.date).getTime());
}

export async function getAlbumBySlug(slug: string): Promise<Album | undefined> {
    const albums = await getAlbums();
    return albums.find(a => a.slug === slug);
}

// Function to resolve all image imports from content
export function getOptimizedImages() {
    // Using import.meta.glob to let Astro handle the actual image files
    // We specify the path relative to the src/utils directory. Wait, the glob route in Astro requires
    // the path to be static. So we glob the whole content/albums structure from the root.
    // Actually, import.meta.glob paths must be string literals.
    const images = import.meta.glob('/content/albums/**/*.{jpg,jpeg,png,webp,avif}');
    return images;
}

// Function to get a specific optimized image module by path
export async function getGlobalAlbumImage(albumSlug: string, filename: string) {
    const images = import.meta.glob('/content/albums/**/*.{jpg,jpeg,png,webp,avif}');
    const searchPath = `/content/albums/${albumSlug}/${filename}`;
    for (const [path, resolver] of Object.entries(images)) {
        if (path === searchPath) {
            return (await resolver() as any).default;
        }
    }
    return null;
}
