import { z, defineCollection } from 'astro:content';

const blogCollection = defineCollection({
    type: 'content',
    schema: ({ image }) => z.object({
        title: z.string(),
        description: z.string(),
        pubDate: z.date(),
        author: z.string().default('Saiful'),
        coverImage: image().optional(),
        tags: z.array(z.string()).default([]),
    })
});

export const collections = {
    'blog': blogCollection,
};
