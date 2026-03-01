import fs from 'fs';
import path from 'path';

const basePath = process.cwd();
const contentAlbumsPath = path.join(basePath, 'content', 'albums');
const categoriesPath = path.join(basePath, 'content', 'categories.json');
const featuredPath = path.join(basePath, 'content', 'featured.json');

const directories = [
    { name: 'BirthDay Photoshoot', slug: 'birthday-photoshoot', category: 'events' },
    { name: 'Graduation Photoshoot', slug: 'graduation-photoshoot', category: 'events' },
    { name: 'Maternity Photoshoot', slug: 'maternity-photoshoot', category: 'events' },
    { name: 'Photoshoot in Saree', slug: 'saree-shoot', category: 'portraits' },
    { name: 'Pitha Uthsob', slug: 'pitha-uthsob', category: 'cultural' }
];

let featuredImages = [];
let allCategories = JSON.parse(fs.readFileSync(categoriesPath, 'utf-8'));

directories.forEach(dir => {
    const sourcePath = path.join(basePath, dir.name);
    if (!fs.existsSync(sourcePath)) return;

    const destPath = path.join(contentAlbumsPath, dir.slug);

    // Move directory to content/albums/
    fs.renameSync(sourcePath, destPath);

    // Read photos
    const files = fs.readdirSync(destPath).filter(f => f.toLowerCase().endsWith('.jpg') || f.toLowerCase().endsWith('.png'));

    const photos = files.map((file, index) => {
        const isFeatured = index === 0;
        if (isFeatured) {
            featuredImages.push({
                albumSlug: dir.slug,
                file: file,
                title: dir.name,
                category: dir.category
            });

            // Update category cover image if missing
            const catObj = allCategories.find(c => c.slug === dir.category);
            if (catObj && !catObj.cover) {
                catObj.cover = `albums/${dir.slug}/${file}`;
            }
        }
        return {
            file,
            caption: `${dir.name} - Photo ${index + 1}`,
            featured: isFeatured
        };
    });

    const albumMeta = {
        title: dir.name,
        slug: dir.slug,
        date: "2025-01-01",
        location: "Studio",
        categories: [dir.category],
        description: `A collection from ${dir.name}.`,
        cover: files[0] || "",
        photos
    };

    fs.writeFileSync(path.join(destPath, '_album.json'), JSON.stringify(albumMeta, null, 2));
});

fs.writeFileSync(featuredPath, JSON.stringify(featuredImages, null, 2));
fs.writeFileSync(categoriesPath, JSON.stringify(allCategories, null, 2));

console.log("Migration complete!");
